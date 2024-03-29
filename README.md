# Measuring -DNO_TAINT_SUPPORT in Perl

This is about benchmarking the impact of a `-DNO_TAINT_SUPPORT` option
in Perl 5. These notes here should make the exercise reproducable.

The toolchain and philosophy is that of [Perl::Formance](http://renormalist.github.io/Benchmark-Perl-Formance/).

# Preparation

Setting things up, extend tools, sample runs.

## Checklist

- [x] setup CPAN mirror
- [x] setup `bootstrap-perl`
- [x] install a sample bleadperl via bootstrap-perl
- [x] install `perlformance`
- [x] extend bootstrap-perl for `NO_TAINT_SUPPORT` option
- [x] extend perlformance for `NO_TAINT_SUPPORT` option and metainfo
- [x] setup/reuse existing `benchmark-anything` and/or `Tapper` setup
- [x] sample run/reporting/querying
- [x] setup/reuse Jupyter for more evaluations
- [ ] setup and run `Benchmark::Perl::Formance::Analyzer` and `BenchmarkAnything::Evaluations`
- [ ] Do The Right Thing - do everything again for real on a silenced machine


## Package dependencies

```
sudo apt-get install make patch makepatch curl wget rsync gcc g++ git perl-modules libbz2-1.0 libbz2-dev libdb-dev libsqlite3-dev linux-source libgmp3-dev libssl-dev libpcre3-dev
```

## Extend bootstrap-perl with --notaintsupport option

See
[this](https://github.com/renormalist/app-bootstrap-perl/commit/b91b85b462a8907325102d6b2ec038e4a22d4416) and
[that](https://github.com/renormalist/app-bootstrap-perl/commit/3d215db51476cbb7f388be41c27fb458c7093543)
commit for taintmode building and also the other commits nearby.

## Setting up CPAN mirror

```
mkdir -p ~/CPAN/
cpanm File::Rsync::Mirror::Recent
rrr-client  --source cpan-rsync.perl.org::CPAN/RECENT.recent --target ~/CPAN/
```

...and wait until it settled with 25+ GB.

## Setting up App::Bootstrap::Perl

```bash
cpanm App::Bootstrap::Perl
```

## Install a standard bleadperl

Do it:

```bash
bootstrap-perl -j 32 --version blead --cpan -m file://$HOME/CPAN/ --taintsupport -M Task::PerlFormance
```

Verify:

```bash
$ ls -1 ~/.bootstrapperl/$HOSTNAME/
  cpan
  perl-5.35-thread-64bit-taint-v5.35.3-151-g6128f436ce
$ ~/.bootstrapperl/$HOSTNAME/perl-5.35-thread-64bit-taint-v5.35.3-151-g6128f436ce/bin/perl -v
  This is perl 5, version 35, subversion 4 (v5.35.4 (v5.35.3-151-g6128f436ce)) built for x86_64-linux-thread-multi
$ ~/.bootstrapperl/$HOSTNAME/perl-5.35-thread-64bit-taint-v5.35.3-151-g6128f436ce/bin/perl -MConfig -E 'say $Config{config_args}'
  -der -Dusedevel -Dusethreads -Duse64bitall -Dprefix=/home/ss5/.bootstrapperl/ss5z/perl-5.35-thread-64bit-taint-v5.35.3-151-g6128f436ce
```

## Install a bleadperl with no taint support

This Perl fails when trying to use taint mode.

Do it:

```bash
bootstrap-perl -j 32 --version blead --cpan -m file://$HOME/CPAN/ --notaintsupport -M Task::PerlFormance
```

Verify:

```bash
$ ls -1 ~/.bootstrapperl/$HOSTNAME/
  cpan
  perl-5.35-thread-64bit-notaint-v5.35.3-151-g6128f436ce
  perl-5.35-thread-64bit-taint-v5.35.3-151-g6128f436ce
$ ~/.bootstrapperl/$HOSTNAME/perl-5.35-thread-64bit-notaint-v5.35.3-151-g6128f436ce/bin/perl -v
  This is perl 5, version 35, subversion 4 (v5.35.4 (v5.35.3-151-g6128f436ce)) built for x86_64-linux-thread-multi
$ ~/.bootstrapperl/$HOSTNAME/perl-5.35-thread-64bit-notaint-v5.35.3-151-g6128f436ce/bin/perl -MConfig -E 'say $Config{config_args}'
  -der -Dusedevel -Dusethreads -Duse64bitall -Accflags=-DNO_TAINT_SUPPORT -Dprefix=/home/ss5/.bootstrapperl/ss5z/perl-5.35-thread-64bit-notaint-v5.35.3-151-g6128f436ce
```

## Install a bleadperl with silent no taint support

This Perl does not fail but silently ignores the taint checks.

Explicitely specify commit as I did this days later.

Do it:

```bash
bootstrap-perl -j 32 --version blead --cpan -m file://$HOME/CPAN/ --notaintsupport --silentnotaint --version 6128f436ce -M Task::PerlFormance
```

Verify:

```bash
$ ls -1 ~/.bootstrapperl/$HOSTNAME/
  cpan
  perl-5.35-thread-64bit-notaint-v5.35.3-151-g6128f436ce
  perl-5.35-thread-64bit-taint-v5.35.3-151-g6128f436ce
$ ~/.bootstrapperl/$HOSTNAME/perl-5.35-thread-64bit-notaint-v5.35.3-151-g6128f436ce/bin/perl -v
  This is perl 5, version 35, subversion 4 (v5.35.4 (v5.35.3-151-g6128f436ce)) built for x86_64-linux-thread-multi
$ ~/.bootstrapperl/$HOSTNAME/perl-5.35-thread-64bit-notaint-v5.35.3-151-g6128f436ce/bin/perl -MConfig -E 'say $Config{config_args}'
  -der -Dusedevel -Dusethreads -Duse64bitall -Accflags=-DNO_TAINT_SUPPORT -Dprefix=/home/ss5/.bootstrapperl/ss5z/perl-5.35-thread-64bit-notaint-v5.35.3-151-g6128f436ce
```

## Check taint support:

Normal Perl:

```
$ /home/ss5/.bootstrapperl/ss5z/perl-5.35-thread-64bit-taint-v5.35.3-151-g6128f436ce/bin/perl            -MScalar::Util -MCwd -E 'say Scalar::Util::tainted(Cwd::getcwd())'
  0
$ /home/ss5/.bootstrapperl/ss5z/perl-5.35-thread-64bit-taint-v5.35.3-151-g6128f436ce/bin/perl         -T -MScalar::Util -MCwd -E 'say Scalar::Util::tainted(Cwd::getcwd())'
  1
```

No taint support:

```
$ /home/ss5/.bootstrapperl/ss5z/perl-5.35-thread-64bit-notaint-v5.35.3-151-g6128f436ce/bin/perl          -MScalar::Util -MCwd -E 'say Scalar::Util::tainted(Cwd::getcwd())'
  0
$ /home/ss5/.bootstrapperl/ss5z/perl-5.35-thread-64bit-notaint-v5.35.3-151-g6128f436ce/bin/perl       -T -MScalar::Util -MCwd -E 'say Scalar::Util::tainted(Cwd::getcwd())'
  This perl was compiled without taint support. Cowardly refusing to run with -t or -T flags.
```

Silent no taint support:

```
$ /home/ss5/.bootstrapperl/ss5z/perl-5.35-thread-64bit-silentnotaint-v5.35.3-151-g6128f436ce/bin/perl    -MScalar::Util -MCwd -E 'say Scalar::Util::tainted(Cwd::getcwd())'
  0
$ /home/ss5/.bootstrapperl/ss5z/perl-5.35-thread-64bit-silentnotaint-v5.35.3-151-g6128f436ce/bin/perl -T -MScalar::Util -MCwd -E 'say Scalar::Util::tainted(Cwd::getcwd())'
  0
```

## Force install CPAN modules that refuse to run tests without taint support

When using Perl with no taint support many test suites fail because
they explicitely test and insist on it. I reviewed the builds to get a
list of modules that only fail due to that reason but look ok
otherwise, so we can force install them first, and the others should
work normal.

Alternatively, you can build Perl with and additional option
`--silentnotaint` (this came after the below list) but some modules
that explicitely test their tainting still fail.

```
for i in \
 Data::OptList \
 Sub::Exporter \
 Module::Runtime \
 Module::Pluggable \
 Module::Implementation \
 Test::Pod \
 Data::YAML \
 Test::Exception \
 Test::Differences \
 Test::Most \
 Test::Output \
 Benchmark::Perl::Formance::Cargo \
 Mail::SpamAssassin \
 Mock::Config \
 Mouse \
 Module::Pluggable \
 Test2::Suite \
 Test2::Require::Module \
 Test2::Plugin::NoWarnings \
; do \
    /home/ss5/.bootstrapperl/ss5z/perl-5.35-thread-64bit-notaint-v5.35.3-151-g6128f436ce/bin/mycpan -i $i  \
 || /home/ss5/.bootstrapperl/ss5z/perl-5.35-thread-64bit-notaint-v5.35.3-151-g6128f436ce/bin/mycpan -f $i ; \
done
```

Still some struggling with silentnotaint perl but generally looked ok:

```
for i in \
 Mail::SpamAssassin \
 IPC::System::Simple \
; do \
    /home/ss5/.bootstrapperl/ss5z/perl-5.35-thread-64bit-silentnotaint-v5.35.3-151-g6128f436ce/bin/mycpan -T -i $i  ; \
done
```

## Other manual dependencies

```
for i in \
 Perl::Critic \
; do \
    /home/ss5/.bootstrapperl/ss5z/perl-5.35-thread-64bit-notaint-v5.35.3-151-g6128f436ce/bin/mycpan -i $i ; \
done
```

## Extend Perl::Formance to generate taintsupport metainfo

See for instance
[this](https://github.com/renormalist/Benchmark-Perl-Formance/commit/0461a1a5ae2cd548c57fcba782ae77f63f2d43df)
and
[that](https://github.com/renormalist/Benchmark-Perl-Formance/commit/d4f8cf9449e9a8b0b4833e317a3ac28b30dc474a)
github commit.

## Sample perlformance run

On a busy system, no OS silencing etc., just whether it works at all.

```
$ ~/.bootstrapperl/$HOSTNAME/perl-5.35-thread-64bit-taint-v5.35.3-151-g6128f436ce/bin/benchmark-perlformance -vv --plugin PerlStone2015
  # Run PerlStone2015...
  perlformance.perl5.PerlStone2015.01overview.opmix1          : 22.962956
  perlformance.perl5.PerlStone2015.01overview.opmix2          : 22.046787
  perlformance.perl5.PerlStone2015.04control.blocks1          : 36.106382
  perlformance.perl5.PerlStone2015.04control.blocks2          : 21.781852
  perlformance.perl5.PerlStone2015.05regex.fixedstr           : 0.385402
  perlformance.perl5.PerlStone2015.07lists.push               : 21.007447
  perlformance.perl5.PerlStone2015.07lists.unshift            : 25.091016
  perlformance.perl5.PerlStone2015.09data.a_alloc             : 20.469161
  perlformance.perl5.PerlStone2015.09data.a_copy              : 20.872538
  perlformance.perl5.PerlStone2015.binarytrees                : 40.854951
  perlformance.perl5.PerlStone2015.fannkuch                   : 18.634387
  perlformance.perl5.PerlStone2015.fasta                      : 13.466267
  perlformance.perl5.PerlStone2015.fib                        : 22.286073
  perlformance.perl5.PerlStone2015.mandelbrot                 : 42.647786
  perlformance.perl5.PerlStone2015.nbody                      : 15.411557
  perlformance.perl5.PerlStone2015.regex.backtrack            : 82.912121
  perlformance.perl5.PerlStone2015.regex.code_literal         : 18.635276
  perlformance.perl5.PerlStone2015.regex.code_runtime         : 17.235928
  perlformance.perl5.PerlStone2015.regex.precomp_access       : 40.666219
  perlformance.perl5.PerlStone2015.regex.runtime_comp         : 9.012792
  perlformance.perl5.PerlStone2015.regex.runtime_comp_nocache : 102.108240
  perlformance.perl5.PerlStone2015.regex.split1               : 14.954258
  perlformance.perl5.PerlStone2015.regex.split2               : 1.401907
  perlformance.perl5.PerlStone2015.regex.splitratio           : 10.667083
  perlformance.perl5.PerlStone2015.regex.trie_limit           : 0.061215
  perlformance.perl5.PerlStone2015.regexdna                   : 14.477193
  perlformance.perl5.PerlStone2015.spectralnorm               : 51.374912
```

With no taint support:

```
$ ~/.bootstrapperl/$HOSTNAME/perl-5.35-thread-64bit-notaint-v5.35.3-151-g6128f436ce/bin/benchmark-perlformance -vv --plugin PerlStone2015
# Run PerlStone2015...
perlformance.perl5.PerlStone2015.01overview.opmix1          : 25.905277
perlformance.perl5.PerlStone2015.01overview.opmix2          : 23.537931
perlformance.perl5.PerlStone2015.04control.blocks1          : 39.387338
perlformance.perl5.PerlStone2015.04control.blocks2          : 23.935349
perlformance.perl5.PerlStone2015.05regex.fixedstr           : 0.382134
perlformance.perl5.PerlStone2015.07lists.push               : 21.421979
perlformance.perl5.PerlStone2015.07lists.unshift            : 21.956580
perlformance.perl5.PerlStone2015.09data.a_alloc             : 14.874009
perlformance.perl5.PerlStone2015.09data.a_copy              : 19.383048
perlformance.perl5.PerlStone2015.binarytrees                : 41.893024
perlformance.perl5.PerlStone2015.fannkuch                   : 18.586717
perlformance.perl5.PerlStone2015.fasta                      : 12.845734
perlformance.perl5.PerlStone2015.fib                        : 23.897581
perlformance.perl5.PerlStone2015.mandelbrot                 : 40.108169
perlformance.perl5.PerlStone2015.nbody                      : 15.832695
perlformance.perl5.PerlStone2015.regex.backtrack            : 97.042373
perlformance.perl5.PerlStone2015.regex.code_literal         : 19.319733
perlformance.perl5.PerlStone2015.regex.code_runtime         : 16.817169
perlformance.perl5.PerlStone2015.regex.precomp_access       : 39.664139
perlformance.perl5.PerlStone2015.regex.runtime_comp         : 13.931910
perlformance.perl5.PerlStone2015.regex.runtime_comp_nocache : 118.710501
perlformance.perl5.PerlStone2015.regex.split1               : 15.376382
perlformance.perl5.PerlStone2015.regex.split2               : 1.351537
perlformance.perl5.PerlStone2015.regex.splitratio           : 11.376960
perlformance.perl5.PerlStone2015.regex.trie_limit           : 0.049174
perlformance.perl5.PerlStone2015.regexdna                   : 14.619103
perlformance.perl5.PerlStone2015.spectralnorm               : 50.889741
```

With silent no taint support:

```
$ ~/.bootstrapperl/$HOSTNAME/perl-5.35-thread-64bit-silentnotaint-v5.35.3-151-g6128f436ce/bin/benchmark-perlformance -vv --plugin PerlStone2015
```

## Generating meta information in BenchmarkAnything or Tapper environment

Define a common id that gets into the metainfo so we can distinguish
the results, eg. experimental vs. real data.

Use the (new) --tap options to generate everything as TAP with the
data in embedded YAMLish2, so it's easy to feed into an existing
Tapper infrastructure for easier processing later.

```
$ export PERLFORMANCE_QUALID=notaint-2021-dummy01
$ ~/.bootstrapperl/$HOSTNAME/perl-5.35-thread-64bit-taint-v5.35.3-151-g6128f436ce/bin/benchmark-perlformance --plugin PerlStone2015.fasta --fastmode --tap-plan 1 --tap-headers
  [...a big TAP report with results]
$ ~/.bootstrapperl/$HOSTNAME/perl-5.35-thread-64bit-notaint-v5.35.3-151-g6128f436ce/bin/benchmark-perlformance --plugin PerlStone2015.fasta --fastmode --tap-plan 1 --tap-headers
  [...a big TAP report with results]
```

Reporting multiple such experimental data points into Tapper:

```
$ export TAPPER_REPORT_SERVER=...
$ for i in $(seq 1 40); do ~/.bootstrapperl/$HOSTNAME/perl-5.35-thread-64bit-notaint-v5.35.3-151-g6128f436ce/bin/benchmark-perlformance --plugin PerlStone2015.fasta --fastmode --tap-plan 1 --tap-headers | netcat -q1 $TAPPER_REPORT_SERVER 7357 ; sleep $(rand -M 4); done
$ for i in $(seq 1 40); do ~/.bootstrapperl/$HOSTNAME/perl-5.35-thread-64bit-taint-v5.35.3-151-g6128f436ce/bin/benchmark-perlformance --plugin PerlStone2015.fasta --fastmode --tap-plan 1 --tap-headers | netcat -q1 $TAPPER_REPORT_SERVER 7357 ; sleep $(rand -M 4); done
```

## Checking which other perlformance plugins work:

- [x] Mandelbrot
- [x] SpamAssassin (with silentnotaint)
- [x] RxMicro
- [x] MatrixReal
- [x] Fib
- [x] FibOO
- [x] FibMoose
- [x] FibMouse
- [x] FibOOSig
- [x] DPath
- [x] Mem
- [x] AccessorsArray
- [x] AccessorsClassAccessor
- [x] AccessorsClassAccessorFast
- [x] AccessorsClassMethodMaker
- [x] AccessorsClassXSAccessor
- [x] AccessorsClassXSAccessorArray
- [x] AccessorsHash
- [x] AccessorsMoo
- [x] AccessorsMoose
- [x] AccessorsMouse
- [x] AccessorsObjectTinyRW
- [x] Threads
- [x] ThreadsShared
- [-] Rx (fastmode fails)
- [-] RxCmp (fragile pluggable rx engines)
- [-] Prime (GMPz error)
- [-] P6STD (struggles)
- [?] PerlCritic (dependency struggles?)

## Evaluation / Charts

(using a Jupyter instance with BenchmarkAnything support libs)

# Execution

The Real Deal.

Examples, just loop for some data points:

```
for i in $(seq 1 20); do \
  for j in taint notaint ; do \
      ~/.bootstrapperl/$HOSTNAME/perl-5.35-thread-64bit-$j-v5.35.3-151-g6128f436ce/bin/benchmark-perlformance \
        --plugin PerlStone2015
        --tap-plan 1 \
        --tap-headers \
      | netcat -q1 $TAPPER_REPORT_SERVER 7357 ; \
  done ;\
  sleep 1; \
  echo -n "... one iteration done - "; \
  date; \
done
```

SpamAssassin uses the `SILENT_NO_TAINT_SUPPORT` Perl:

```
for i in $(seq 1 40); do \
  for j in taint silentnotaint; do \
    ~/.bootstrapperl/$HOSTNAME/perl-5.35-thread-64bit-$j-v5.35.3-151-g6128f436ce/bin/benchmark-perlformance \
      --plugin SpamAssassin \
      --tap-plan 1 \
      --tap-headers \
    | netcat -q1 $TAPPER_REPORT_SERVER 7357 ; \
  done ; \
  sleep 1; \
  echo -n "... one iteration done - "; \
  date; \
done
```

## Silencing OS noise

```bash
sudo service --status-all;
sudo service metricbeat stop;
sudo service kibana stop;
sudo service logstash stop;
sudo service elasticsearch stop;
sudo service docker stop;
sudo service postgresql stop;
sudo service apache2 stop;
sudo service cups stop;
sudo service cups-browsed stop;
sudo service munin-node stop;
sudo service mysql stop;
sudo service redis-server stop;
sudo service bluetooth stop;
sudo service apache-htcacheclean stop;
sudo service unattended-upgrades stop;
sudo service conserver-server stop;
sudo service speech-dispatcher stop;
sudo service --status-all;
```
