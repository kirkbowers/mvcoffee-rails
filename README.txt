= mvcoffee-rails

{Source}[https://github.com/kirkbowers/mvcoffee-rails]

{Home Page}[http://mvcoffee.org]

== Description

+mvcoffee-rails+ is a Rails gem that makes it easy to use the 
MVCoffee[https://github.com/kirkbowers/mvcoffee] client-side MVC framework in your
Rails project.

The full documentation for this gem is at {mvcoffee.org}[http://mvcoffee.org/mvcoffee-rails].

== Developers/Contributing

Contributing to this project is of course welcome.  There are a couple areas in which I
could really use help:

* Testing:  I'm sure I'll get scolded for this, but not all testing is done with automated unit tests.  In order to be truly confident the gem is working as expected, it 
needs to be exercised in the context of a fully functioning Rails project.  
I have added a toy rails project (+test_rails_project+) as part of the source that
both allows you to exercise the gem in a blackbox fashion, plus supplies some automated
tests where possible.  How to test
the gem in isolation, and have that actually prove anything, strikes me as extremely
non-trivial.  If this type of thing is your specialty, I'd be
very grateful for guidance.
* Autogenerating model validations and associations:  The Class Macro method-like syntax for
defining models in MVCoffee eases the pain of Repeating Yourself on the client, but you
still have to manually Repeat Yourself.  Ideally, there would be a command-line utility
that inspects the Rails definitions of models and auto-generates the corresponding
MVCoffee definitions, guaranteeing they mirror each other accurately.

If you are interested, please feel free to {contact me}[http://mvcoffee.org/contact].

== License

+mvcoffee-rails+ is released under the MIT license.  

