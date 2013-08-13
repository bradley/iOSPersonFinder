Displays People Known to the User
===========

This project will show a searchable table with names and images of people known to a given user.
The project allows the user to find people either from his or her contacts or from his or her Facebook.


NOTE: This project is essentially a combination of the following two projects:
https://github.com/bradley/iOSFacebookFriendFinder
https://github.com/bradley/iOSUserContactFinder


## Connecting with Facebook

This project will handle connecting to Facebook using two methods.
First, if the user has connected his or her device to Facebook using the
Social Framework (i.e.; by initiating a Facebook account in their device
settings), the application will attempt to connect via this method. If
the user has not done this, the application uses the Facebook SDK as a
fallback.

There a few things that need to be done in order for this to work with
Facebook.

1. Create a new application at http://developers.facebook.com/apps

2. In the 'Select how your app integrates with Facebook' settings,
expand the 'Native iOS App' section and type in your Bundle ID where it
asks you to do so. For example:

```
yakamoto.FacebookFriends
```

3. Check the radio button in the same section for 'Facebook Login'

4. Follow the instructions in Section #5 here:
https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/

*Note: You will want to pay special attention to the methods included in 
AppDelegate. Specifically inside of application:openURL:sourceApplication:annotation:
and applicationDidBecomeActive:*

##Searching

Note that there is an extra search feature. Searches done on the friend 
list have been designed to return results with the best user experience 
in mind, which in this case means making some assumptions.

Here we assume that when searching for a friend, a user will do so by 
first name. We therefore return results that begin with the search text
first. This means that Garrett Burnett will appear before Brandon
Garrett when searching for 'Garrett'.
