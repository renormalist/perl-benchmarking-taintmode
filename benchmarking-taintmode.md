# Benchmarking taintmode (-DNO_TAINT_SUPPORT)


I will try to benchmark the impact of the compilation option
-DNO_TAINT_SUPPORT to perl's performance.

For that I will use my Perl::Formance framework, which takes care of
generating reliable numbers with meta information. Past results and
presentations can be found here:

 * [http://renormalist.github.io/Benchmark-Perl-Formance/](http://renormalist.github.io/Benchmark-Perl-Formance/)

The latest short summary is from PerlCon 2019:

 * [http://renormalist.github.io/Benchmark-Perl-Formance/res/2019-08-08-perlcon-riga-perlformance-status.pdf](http://renormalist.github.io/Benchmark-Perl-Formance/res/2019-08-08-perlcon-riga-perlformance-status.pdf)


## Overview:

The focus of the Perl::Formance project is on real world Perl with
CPAN dependencies. However, there are also some micro benchmarks
contained.

In contrast to earlier years where I measured Perl versions over time,
for the taintmode exercise I will only build one blead version from git
with two configurations: with and without taintmode.

To ensure dependency stability I use a static local CPAN mirror, maybe
tweaked with distroprefs. It gets a latest sync and then no updates
anymore.


## Hardware:

I will do it on an Intel i7-10610U from 2020 (4 core, 8 threads, maybe
with threading switched off). When I have time I can maybe do the same
on an AMD Phenom II X6 from 2009, and an older i7 from 2012.


## Benchmarks:

I will run as many as possible plugins from the Perl::Formance suite,
starting with the easiest (PerlStone2015), later trying the harder
ones, like SpamAssassin. Each benchmark runs multiple iterations.

 * [https://metacpan.org/pod/Benchmark::Perl::Formance::Plugin::PerlStone2015](https://metacpan.org/pod/Benchmark::Perl::Formance::Plugin::PerlStone2015)
 

## Results:

I should provide simple "charts", probably looking a bit silly, with
just two data points per benchmark representing an average, plus raw
values about the standard deviation and confidence intervall (ci_95
lower+upper value), like here:

 * [http://renormalist.github.io/Benchmark-Perl-Formance/charts/perlformance/index.html](http://renormalist.github.io/Benchmark-Perl-Formance/charts/perlformance/index.html)
 * [http://renormalist.github.io/Benchmark-Perl-Formance/charts/perlformance/raw-numbers.txt](http://renormalist.github.io/Benchmark-Perl-Formance/charts/perlformance/raw-numbers.txt)

(Remember, it will look more silly with only 2 data points for the two
variants of one common perl version.)

If I can draw a single-sentence conclusion, I will do.


## Bonus results:

Only when I'm feeling lucky I might generate different charts types from
the raw data to better present the result distribution (histogram,
whisker plot, you name it), but I can not promise that.


## Risks:

 1) Having no taintmode might fail some test suites of CPAN
    dependencies. I will have to skip the tests, interfere, or
    "force". Broken or missing deps can theoretically lead to different
    code paths behind the scenes.

 2) I haven't done any Perl after v5.30 yet with latest CPAN
    lately. Everything can go wrong.


## Contributions:

If you want to contribute code snippets to get benchmarked, then
copy/paste/extend a module for the PerlStone2015 plugin and send a pull
request:

 * [https://metacpan.org/pod/Benchmark::Perl::Formance::Plugin::PerlStone2015](https://metacpan.org/pod/Benchmark::Perl::Formance::Plugin::PerlStone2015)

Have a look at fib.pm for an easy start.


## Timeframe:

I have a block of spare time available in the week from 2021-09-13.

EOF.
