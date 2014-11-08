package com.example.selena_wang.frontend;

/**
 * Created by selena_wang on 11/6/14.
 */

 import com.android.uiautomator;
//import com.android.uiautomator.core.UiObject;
//import com.android.uiautomator.core.UiObjectNotFoundException;
//import com.android.uiautomator.core.UiScrollable;
//import com.android.uiautomator.core.UiSelector;
//import com.android.uiautomator.testrunner.UiAutomatorTestCase;

public class UITest extends UiAutomatorTestCase {

    public void test() throws UiObjectNotFoundException {

        // Simulate a short press on the HOME button.
        getUiDevice().pressHome();

        // We’re now in the home screen. Next, we want to simulate
        // a user bringing up the All Apps screen.
        // If you use the uiautomatorviewer tool to capture a snapshot
        // of the Home screen, notice that the All Apps button’s
        // content-description property has the value “Apps”.  We can
        // use this property to create a UiSelector to find the button.
        UiObject allAppsButton = new UiObject(new UiSelector()
                .description("Apps"));

        // Simulate a click to bring up the All Apps screen.
        allAppsButton.clickAndWaitForNewWindow();

        // In the All Apps screen, the Settings app is located in
        // the Apps tab. To simulate the user bringing up the Apps tab,
        // we create a UiSelector to find a tab with the text
        // label “Apps”.
        UiObject appsTab = new UiObject(new UiSelector()
                .text("Apps"));

        // Simulate a click to enter the Apps tab.
        appsTab.click();

        // Next, in the apps tabs, we can simulate a user swiping until
        // they come to the Settings app icon.  Since the container view
        // is scrollable, we can use a UiScrollable object.
        UiScrollable appViews = new UiScrollable(new UiSelector()
                .scrollable(true));

        // Set the swiping mode to horizontal (the default is vertical)
        appViews.setAsHorizontalList();

        // Create a UiSelector to find the Settings app and simulate
        // a user click to launch the app.
        UiObject caravanApp = appViews.getChildByText(new UiSelector()
                        .className(android.widget.TextView.class.getName()),
                "Log In");
        caravanApp.clickAndWaitForNewWindow();

        // Validate that the package name is the expected one
        UiObject caravanValidation = new UiObject(new UiSelector()
                .packageName("com.example.selena_wang.frontend"));
        assertTrue("Unable to detect Caravan",
                caravanValidation.exists());

        UiObject caravanUserInput = new UiObject(new UiSelector().resourceId("inputUser"));
        UiObject caravanPassInput = new UiObject(new UiSelector().resourceId("inputPass"));
        UiObject caravanLogin = new UiObject(new UiSelector().resourceId("loginButton"));

        assertTrue("No User Input",caravanUserInput.exists());
        assertTrue("No Password Input",caravanPassInput.exists());

        caravanUserInput.setText("byran8");
        caravanPassInput.setText("byran");
        caravanLogin.clickAndWaitForNewWindow();

        UiObject friendButton = new UiObject(new UiSelector().resourceId("friend_icon"));
        assertTrue("No Friend Button",friendButton.exists());
        friendButton.clickAndWaitForNewWindow();

        UiObject findfriendButton = new UiObject(new UiSelector().resourceId("findFriends"));
        assertTrue("No Find Friend Button",friendButton.exists());
        findfriendButton.clickAndWaitForNewWindow();

        UiObject searchButton = new UiObject(new UiSelector().resourceId("searchButton"));
        assertTrue("Did not go to Find Friends",searchButton.clickable());
        friendButton.clickAndWaitForNewWindow();
        assertFalse("Did not go to Find Friends",searchButton.clickable());

        UiObject homeButton = new UiObject(new UiSelector().resourceId("home"))
        homeButton.clickAndWaitForNewWindow();

        UiObject createButton = new UiObject(new UiSelector().resourceId("create_icon"));
        assertTrue("No Create Button", createButton.exists());
        createButton.clickAndWaitForNewWindow();

        UiObject caravanMapButton = new UiObject(new UiSelector().resourceId("caravanMap"));
        assertTrue("Did not go to Create Caravan",searchButton.clickable());

        homeButton.clickAndWaitForNewWindow();

        UiObject caravanButton = new UiObject(new UiSelector().resourceId("caravan_icon"));
        assertTrue("No Caravan Button",caravanButton.exists());
        caravanButton.clickAndWaitForNewWindow();

        UiObject map = new UiObject(new UiSelector().resourceId("map"));
        assertTrue("No Map",map.exists());


    }
}
