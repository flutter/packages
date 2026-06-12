Title: Live Content

Description: Fetched live

Source: https://raw.githubusercontent.com/android/skills/main/devtools/android-cli/references/journeys.md

---

A journey is an XML-specified test of an Android app's behavior. It consists of a list of `<action>` elements. For example:
```xml
<journey name="My Journey">
   <description>
      A sample journey to illustrate the format
   </description>
   <actions>
     <action>
       Tap the "Home" icon
     </action>
     <action>
       Verify that the app is on its Home screen
     </action>
   </actions>
</journey>
```

Evaluate a journey by proceeding through the `<actions>` list in sequential order. Evaluate each `<action>` block individually.
A journey succeeds if all elements in the `<actions>` list succeed.

A journey is a test case for an app. The journey XML is the source of truth; if the app disagrees with the journey, the app has failed.
Additionally, if the app exits, crashes, or freezes, journey evaluation stops and the journey fails.

**IMPORTANT** - Execute each step EXACTLY as written, and independently of other steps! If an action says to `"tap the first search result"`,
you MUST find the search results and tap the first one. Do this even if you believe you know the intent behind the action.

## Taking Actions
Some `<action>` elements specify UI interactions to perform on the running Android app. Perform the interaction and verify that the app does 
not crash or behave in an unexpected manner. This is the *only* verification you should perform for an `<action>`.

If the interaction cannot be performed as specified, the journey fails. 
Example: 
```<action>Click the red button</action>```
If you determine a red button is not present in the UI, the journey fails. 

If the text of an `<action>` specifies a list of actions, break it into sub-actions and evaluate them individually: 
Example:
```<action>Search for soda and add the first result to the cart</action>```
This should be evaluated as:
```
<action>Search for soda</a

