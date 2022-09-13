# Stager Example

A barebones sample app demonstrating how and why you might want to use Scenes.

## Overview

This app shows a Twitter-like UI. It launches to a list of posts, from which you can
navigate to a post detail page. From the post detail page, you can navigate to a user detail page,
which shows the user's name and their posts.

To demonstrate how this works with DI and testing, this also uses [package:provider](https://pub.dev/packages/provider)
and [package:mockito](https://pub.dev/packages/mockito). These only serve to illustrate one way you might
use Stager and are not a requirement.

The app has three pages, each of which have their own scenes. These scenes exercise several different states
for each page, some of which might be a bit diffcult or cumbersome to develop otherwise. For example, developing
a loading screen without Stager might require:

1. A one-off edit to the page code to permanently show a loading state. This would almost certainly never be
committed to source control, and any future developers who want to test this would need to duplicate the work.
2. Using Network Link Conditioner or a similar tool to simulate a bad network connection. This is better than
option 1, but will not be useful when attempting to simulate other states (e.g., empty).
