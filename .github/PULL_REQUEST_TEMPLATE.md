*Replace this paragraph with a description of what this PR is changing or adding, and why. Consider including before/after screenshots.*

*List which issues are fixed by this PR. You must list at least one issue.*

## Pre-Review Checklist

- [ ] I read the [Contributor Guide] and followed the process outlined there for submitting PRs.
- [ ] I read the [Tree Hygiene] page, which explains my responsibilities.
- [ ] I read and followed the [relevant style guides] and ran [the auto-formatter].
- [ ] I signed the [CLA].
- [ ] The title of the PR starts with the name of the package surrounded by square brackets, e.g. `[shared_preferences]`
- [ ] I [linked to at least one issue that this PR fixes] in the description above.
- [ ] I updated `pubspec.yaml` with an appropriate new version according to the [pub versioning philosophy], or I have commented below to indicate which [version change exemption] this PR falls under[^1].
- [ ] I updated `CHANGELOG.md` to add a description of the change, [following repository CHANGELOG style], or I have commented below to indicate which [CHANGELOG exemption] this PR falls under[^1].
- [ ] I updated/added any relevant documentation (doc comments with `///`).
- [ ] I added new tests to check the change I am making, or I have commented below to indicate which [test exemption] this PR falls under[^1].
- [ ] All existing and new tests are passing.

If you need help, consider asking for advice on the #hackers-new channel on [Discord].

**Note**: The Flutter team is currently trialing the use of [Gemini Code Assist for GitHub](https://developers.google.com/gemini-code-assist/docs/review-github-code). Comments from the `gemini-code-assist` bot should not be taken as authoritative feedback from the Flutter team. If you find its comments useful you can update your code accordingly, but if you are unsure or disagree with the feedback, please feel free to wait for a Flutter team member's review for guidance on which automated comments should be addressed.

[^1]: Regular contributors who have demonstrated familiarity with the repository guidelines only need to comment if the PR is not auto-exempted by repo tooling.

<!-- Links -->
[Contributor Guide]: https://github.com/flutter/packages/blob/main/CONTRIBUTING.md
[Tree Hygiene]: https://github.com/flutter/flutter/blob/master/docs/contributing/Tree-hygiene.md
[relevant style guides]: https://github.com/flutter/packages/blob/main/CONTRIBUTING.md#style
[the auto-formatter]: https://github.com/flutter/packages/blob/main/script/tool/README.md#format-code
[CLA]: https://cla.developers.google.com/
[Discord]: https://github.com/flutter/flutter/blob/master/docs/contributing/Chat.md
[linked to at least one issue that this PR fixes]: https://github.com/flutter/flutter/blob/master/docs/contributing/Tree-hygiene.md#overview
[pub versioning philosophy]: https://dart.dev/tools/pub/versioning
[version change exemption]: https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md#version
[following repository CHANGELOG style]: https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md#changelog-style
[CHANGELOG exemption]: https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md#changelog
[test exemption]: https://github.com/flutter/flutter/blob/master/docs/contributing/Tree-hygiene.md#tests
