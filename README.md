BJob - Batch jobs
=================

BJob allows you to write batch jobs. Each job defines a set of items to operate
on plus a processing method that takes one item as an argument.

BJob was designed with observability in mind, so it integrates with [Batch][1]
by default.

Jobs are Ruby classes and can be invoked from anywhere in code. However, since
it's so common to run them straight from the command line, a CLI is built in.

Motivation: Rake sucks
----------------------

In my experience, you have two types of Rake tasks:

1. Batch jobs, which you run either manually or from a crontab.
2. Build tasks, like preparing static assets before deploy.

For build tasks, I find plain old Make to be a much better alternative. It's
designed with that goal in mind, it's language agnostic and it's much easier
and straightforward to shell out. (I was shelling out all the time in my Rake
tasks anyway.)

For batch jobs, Rake just doesn't work. As soon as the logic of your tasks
begins to grow, so does the length of the task—there is no clear way of
factoring out code in order to keep things sane.  You can define global
methods, but that's suboptimal, to say the least. Many times you'll create a
class or module which handles that growing logic. And the Rake task will be
there just to call the class.

I wrote BJob in order to clean up all those ad-hoc classes I'd been creating to
handle batch jobs.

Getting started
---------------

Say you run an application which has paid user accounts. So you want to run
a batch job every day, check for expired accounts and take the appropriate
action:

    class AccountChecker < BJob::Job
      def items(filter = nil)
        User.all
      end

      def process(user)
        if user.subscription_ended?
          user.update(plan: "free")
        end
      end
    end

You can run the job over all user accounts by calling:

    AccountChecker.run

You can also run the job using the built-in CLI interface:

    $ bjob -r./lib/account_checker AccountChecker

In real life it's probable that you have an entry point to your application, a
file which loads everything. In order to save you from repeating yourself on
every call to `bjob(1)`, you can create a `.bjobrc` in the project root:

    $ cat .bjobrc
    -r
    ./init

Each line is appended to Ruby's `ARGV` before processing arguments. So now you
can call the executable like:

    $ bjob AccountChecker

Installation
------------

    $ gem install bjob

License
-------

See `UNLICENSE`. With love, from [Educabilia](http://educabilia.com).

[1]: https://github.com/djanowski/batch
