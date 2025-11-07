import 'package:edemand_partner/app/generalImports.dart';
import 'dart:developer' as developer;

@pragma('vm:entry-point')
Future<void> onBackgroundMessageHandler(RemoteMessage message) async {
  if (message.data["type"] == "chat") {
    //background chat message storing
    final List<ChatNotificationData> oldList =
        await ChatNotificationsRepository().getBackgroundChatNotificationData();
    final messageChatData = ChatNotificationData.fromRemoteMessage(
      remoteMessage: message,
    );
    oldList.add(messageChatData);

    ChatNotificationsRepository().setBackgroundChatNotificationData(
      data: oldList,
    );
    if (Platform.isAndroid) {
      ChatNotificationsUtils.createChatNotification(
        chatData: messageChatData,
        message: message,
      );
    }
  } else {
    if (message.data['type'] == "order" && Platform.isAndroid) {
      localNotification.createSoundNotification(
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        notificationData: message,
        isLocked: false,
      );
    } else {
      if (message.data["image"] == null && Platform.isAndroid) {
        localNotification.createNotification(
          isLocked: false,
          notificationData: message,
          playCustomSound: false,
        );
      } else if (Platform.isAndroid) {
        localNotification.createImageNotification(
          isLocked: false,
          notificationData: message,
          playCustomSound: false,
        );
      }
    }
  }
}

LocalAwesomeNotification localNotification = LocalAwesomeNotification();

class NotificationService {
  static FirebaseMessaging messagingInstance = FirebaseMessaging.instance;

  static late StreamSubscription<RemoteMessage> foregroundStream;
  static late StreamSubscription<RemoteMessage> onMessageOpen;

  static Future<void> requestPermission() async {
    try {
      final NotificationSettings settings = await messagingInstance
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );

      developer.log(
        'Notification permission status: ${settings.authorizationStatus}',
      );
    } catch (e) {
      developer.log('Error requesting notification permission: $e', error: e);
      rethrow;
    }
  }

  static Future<void> init(context) async {
    try {
      developer.log('Initializing notification service...');

      await ChatNotificationsUtils.initialize();
      await requestPermission();
      await registerListeners(context);

      developer.log('Notification service initialized successfully');
    } catch (e) {
      developer.log('Failed to initialize notification service: $e', error: e);
      rethrow;
    }
  }

  static Future<void> foregroundNotificationHandler() async {
    try {
      developer.log('Setting up foreground notification handler...');

      foregroundStream = FirebaseMessaging.onMessage.listen(
        (RemoteMessage message) {
          developer.log('Received foreground message: ${message.messageId}');

          if (message.data["type"] == "chat") {
            ChatNotificationsUtils.addChatStreamAndShowNotification(
              message: message,
            );
          } else {
            //in ios awesome notification will automatically generate a notification
            if (message.data['type'] == "order" && Platform.isAndroid) {
              localNotification.createSoundNotification(
                title: message.notification?.title ?? '',
                body: message.notification?.body ?? '',
                notificationData: message,
                isLocked: false,
              );
            } else {
              if (message.data["image"] == null && Platform.isAndroid) {
                localNotification.createNotification(
                  isLocked: false,
                  notificationData: message,
                  playCustomSound: false,
                );
              } else if (Platform.isAndroid) {
                localNotification.createImageNotification(
                  isLocked: false,
                  notificationData: message,
                  playCustomSound: false,
                );
              }
            }
          }
        },
        onError: (error) {
          developer.log(
            'Error in foreground notification stream: $error',
            error: error,
          );
        },
      );

      developer.log('Foreground notification handler setup complete');
    } catch (e) {
      developer.log(
        'Failed to setup foreground notification handler: $e',
        error: e,
      );
      rethrow;
    }
  }

  static Future<void> terminatedStateNotificationHandler() async {
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) async {
      if (message == null) {
        return;
      }

      // Don't show notification, just handle redirection
      await handleNotificationRedirection(message.data);
    });
  }

  static Future<void> onTapNotificationHandler(BuildContext context) async {
    onMessageOpen = FirebaseMessaging.onMessageOpenedApp.listen((
      final message,
    ) async {
      await handleNotificationRedirection(message.data);
    });
  }

  static Future<void> handleNotificationRedirection(
    Map<String, dynamic> data,
  ) async {
    if (data["type"] == "chat") {
      try {
        if (Routes.currentRoute == Routes.chatMessages) {
          UiUtils.rootNavigatorKey.currentState?.pop();
        }

        await UiUtils.rootNavigatorKey.currentState?.pushNamed(
          Routes.chatMessages,
          arguments: {"chatUser": ChatUser.fromNotificationData(data)},
        );
      } catch (_) {}
    } else if (data["type"] == "order") {
      try {
        final String orderId = data['order_id']?.toString() ?? '';

        if (orderId.isEmpty) {
          return;
        }

        // instance for this notification
        final FetchBookingsDetailsCubit bookingDetailsCubit =
            FetchBookingsDetailsCubit();

        final UpdateBookingStatusCubit updateBookingStatusCubit =
            UpdateBookingStatusCubit();

        await bookingDetailsCubit.fetchBookingDetails(
          bookingId: orderId,
        ); //wait for response

        final state = bookingDetailsCubit.state;
        if (state is FetchBookingsSuccess) {
          await UiUtils.rootNavigatorKey.currentState?.pushNamed(
            Routes.bookingDetails,
            arguments: {
              'bookingsModel': state.bookings.first,
              'cubit': updateBookingStatusCubit,
            },
          );
        }
      } catch (_) {}
    } else if (data["type"] == "job_notification") {
      //navigate to booking tab
      UiUtils
              .mainActivityNavigationBarGlobalKey
              .currentState
              ?.selectedIndexOfBottomNavigationBar
              .value =
          2;
    } else if (data["type"] == "withdraw_request") {
      await UiUtils.rootNavigatorKey.currentState?.pushNamed(
        Routes.withdrawalRequests,
      );
    } else if (data["type"] == "settlement") {
    } else if (data["type"] == "provider_request_status") {
      if (data['status'] == "approve") {
      } else {}
    } else if (data["type"] == "url") {
      final String url = data["url"].toString();
      try {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $url';
        }
      } catch (e) {
        throw 'somethingWentWrongTitle';
      }
    }
  }

  static Future<void> registerListeners(context) async {
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(onBackgroundMessageHandler);

    await foregroundNotificationHandler();
    await terminatedStateNotificationHandler();
    await onTapNotificationHandler(context);
  }

  static void disposeListeners() {
    ChatNotificationsUtils.dispose();

    onMessageOpen.cancel();
    foregroundStream.cancel();
  }
}
