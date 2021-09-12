# Measuring -DNO_TAINT_SUPPORT in Perl - notes and results

This is about benchmarking the impact of a `-DNO_TAINT_SUPPORT` option
in Perl 5. These notes here should make the exercise reproducable.

The toolchain and philosophy is that of [Perl::Formance](http://renormalist.github.io/Benchmark-Perl-Formance/).

## Checklist

- [ ] setup CPAN mirror
- [ ] setup `bootstrap-perl`
- [ ] install a bleadperl via bootstrap-perl
- [ ] install `perlformance`
- [ ] extend bootstrap-perl for `NO_TAINT_SUPPORT` option
- [ ] extend perlformance for `NO_TAINT_SUPPORT` option and metainfo
- [ ] setup/reuse existing `benchmark-anything` setup
- [ ] sample run/reporting/querying
- [ ] setup and run `Benchmark::Perl::Formance::Analyzer` and `BenchmarkAnything::Evaluations`
- [ ] setup/reuse Jupyter for more evaluations
- [ ] Do The Right Thing - do everything again for real on a silenced machine

## Setting up CPAN mirror

