# Guidelines for Updating the App and Panel to the Latest Version:

0. Create BACKUP of your existing admin panel Code & Database before updating. And of App Code.
1. proceed to apply the provided changelogs, updating the app to the latest version.
2. Activate maintenance mode in the admin panel to temporarily disable the app for users.
3. Execute the update scripts within the panel.
4. Thoroughly test the functionality of both the updated panel and app to ensure everything operates as expected.
5. Publish the updated app on both app stores. Once the update is published:
6. In the admin panel, enable force update, add the current app versions, and disable maintenance mode.
7. Note that panel downgrades are not supported. If the panel is updated, it is imperative to also update the app.
8. Throughout the entire process, ensure that maintenance mode is enabled.


# Using Changelog.txt file to update the files in your project.

1. After you have made copy of your current project and kept backup
2. open changelog.txt and go one by one and replace/add/delete files one by one from our provided updated code to your copy of the project.
3. If the same files are changed where you have also made changes then after replacing those files, you will need to add your changes back again.
3. Once done you have updated the app to the latest version. Run and verify that it works as expected


# Using Changed-files folder

If you don't want to manually go one by one and update the app. You can use the changed-files folder which contains only modified and added files which you can directly copy and replace in your project.

It will directly update the modified and added files in your project.

Remember for deleted and renamed files you will still need to manually update them accordingly.
