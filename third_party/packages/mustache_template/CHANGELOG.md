# CHANGELOG

## 0.2

* Deprecated parse() function - please update your code to use new Template(source).
* Deprecated MustacheFormatException - please update your code to use TemplateException.
* Breaking change: Template.render and Template.renderString methods no longer
  take the optional lenient and htmlEscapeValues. These should now be passed to
  the Template constructor.
* Fully passing all mustache spec tests.
* Added support for MirrorsUsed.
* Implemented partials. #11
* Implemented lambdas. #4
* Implemented change delimiter tag.
* Add template name parameter, and show this in error messages.
* Allow whitespace at begining of tags. #10

