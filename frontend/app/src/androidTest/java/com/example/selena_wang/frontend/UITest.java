package com.example.selena_wang.frontend;

/**
 * Created by selena_wang on 11/6/14.
 */

import com.android.uiautomator.core.UiObject;
import com.android.uiautomator.core.UiObjectNotFoundException;
import com.android.uiautomator.core.UiScrollable;
import com.android.uiautomator.core.UiSelector;
import com.android.uiautomator.testrunner.UiAutomatorTestCase;

public class UITest extends UiAutomatorTestCase {

    public void test() throws UiObjectNotFoundException {

        // Simulate a short press on the HOME button.
        getUiDevice().pressHome();

        // Simulate bringing up all apps
        UiObject allAppsButton = new UiObject(new UiSelector()
                .description("Apps"));
        allAppsButton.clickAndWaitForNewWindow();

        // Simulate click to enter apps tab
        UiObject appsTab = new UiObject(new UiSelector()
                .text("Apps"));
        appsTab.click();

        // Simulate a user swiping until they come to the Settings app icon.
        UiScrollable appViews = new UiScrollable(new UiSelector()
                .scrollable(true));
        // Set the swiping mode to horizontal (the default is vertical)
        appViews.setAsHorizontalList();
        // Create a UiSelector to find the App
        UiObject caravanApp = appViews.getChildByText(new UiSelector()
                        .className(android.widget.TextView.class.getName()),
                "Log In");
        caravanApp.clickAndWaitForNewWindow();

        // Validate that the package name is the expected one
        UiObject caravanValidation = new UiObject(new UiSelector()
                .packageName("com.example.selena_wang.frontend"));
        assertTrue("Unable to detect Caravan", caravanValidation.exists());

        //check register
        register();
        checkHome();
        getUiDevice().pressBack();

        //check login
        login();
        checkHome();

        //check friend
        friend();
        goHome();
        checkHome();

        //check create caravan
        createCaravan();
        goHome();
        checkHome();

        //check create map
        caravanMap();
        goHome();
        checkHome();

    }

    public void register() throws UiObjectNotFoundException{
        UiObject caravanUserInput = new UiObject(new UiSelector().resourceId("inputUser"));
        UiObject caravanPassInput = new UiObject(new UiSelector().resourceId("inputPass"));
        UiObject caravanRegister = new UiObject(new UiSelector().resourceId("createButton"));

        assertTrue("No User Input",caravanUserInput.exists());
        assertTrue("No Password Input",caravanPassInput.exists());

        caravanUserInput.setText("byran8");
        caravanPassInput.setText("byran");
        caravanRegister.clickAndWaitForNewWindow();
    }

    public void login() throws UiObjectNotFoundException{
        UiObject caravanUserInput = new UiObject(new UiSelector().resourceId("inputUser"));
        UiObject caravanPassInput = new UiObject(new UiSelector().resourceId("inputPass"));
        UiObject caravanLogin = new UiObject(new UiSelector().resourceId("loginButton"));

        assertTrue("No User Input",caravanUserInput.exists());
        assertTrue("No Password Input",caravanPassInput.exists());

        caravanUserInput.setText("byran8");
        caravanPassInput.setText("byran");
        caravanLogin.clickAndWaitForNewWindow();
    }

    public void friend() throws UiObjectNotFoundException{
        UiObject friendButton = new UiObject(new UiSelector().resourceId("friend_icon"));
        assertTrue("No Friend Button",friendButton.exists());
        friendButton.clickAndWaitForNewWindow();

        UiObject findfriendButton = new UiObject(new UiSelector().resourceId("findFriends"));
        assertTrue("No Find Friend Button",friendButton.exists());
        findfriendButton.clickAndWaitForNewWindow();

        UiObject searchButton = new UiObject(new UiSelector().resourceId("searchButton"));
        assertTrue("Did not go to Find Friends",searchButton.isClickable());
        friendButton.clickAndWaitForNewWindow();
        assertFalse("Did not go to Find Friends",searchButton.isClickable());
    }

    public void createCaravan() throws UiObjectNotFoundException{
        UiObject createButton = new UiObject(new UiSelector().resourceId("create_icon"));
        assertTrue("No Create Button", createButton.exists());
        createButton.clickAndWaitForNewWindow();
    }

    public void caravanMap() throws UiObjectNotFoundException{

        UiObject caravanButton = new UiObject(new UiSelector().resourceId("caravan_icon"));
        assertTrue("No Caravan Button",caravanButton.exists());
        caravanButton.clickAndWaitForNewWindow();

        UiObject map = new UiObject(new UiSelector().resourceId("map"));
        assertTrue("No Map",map.exists());
    }

    public void goHome() throws UiObjectNotFoundException{
        UiObject homeButton = new UiObject((new UiSelector().resourceId("com.android.")));
    }

    public void checkHome() throws UiObjectNotFoundException{

    }

}
