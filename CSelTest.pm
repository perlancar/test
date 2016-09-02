package CSelTest;

use 5.020000;
use strict;
use warnings;

our $RE =
    qr{
          (?&ATTR_SELECTOR) (?{ $_ = $^R->[1] })

          (?(DEFINE)

              (?<ATTR_SELECTOR>
                  \[\s*
                  (?{ [$^R, []] })
                  (?&ATTR_SUBJECTS)
                  (?{
                      $^R->[0][1][0] = $^R->[1];
                      $^R->[0];
                  })

                  (?:
                      (
                          \s*=\s*|
                          #\s*!=\s*| # and so on
                          \s+eq\s+
                          #\s+ne\s+  # and so on
                      )
                      (?{
                          my $op = $^N;
                          $op =~ s/^\s+//; $op =~ s/\s+$//;
                          $^R->[1][1] = $op;
                          $^R;
                      })

                      (?:
                          (?&LITERAL_NUMBER)
                          (?{
                              $^R->[0][1][2] = $^R->[1];
                              $^R->[0];
                          })
                      )
                  )?
                  \s*\]
              )

              (?<ATTR_NAME>
                  [A-Za-z_][A-Za-z0-9_]*
              )

              (?<ATTR_SUBJECT>
                  (?{ [$^R, []] })
                  ((?&ATTR_NAME))
                  (?{
                      push @{ $^R->[1] }, $^N;
                      $^R;
                  })
                  (?:
                      # attribute arguments
                      \s*\(\s*
                      (?{
                          $^R->[1][1] = [];
                          $^R;
                      })
                      (?:
                          (?&LITERAL_NUMBER)
                          (?{
                              push @{ $^R->[0][1][1] }, $^R->[1];
                              $^R->[0];
                          })
                          (?:
                              \s*,\s*
                              (?&LITERAL_NUMBER)
                              (?{
                                  push @{ $^R->[0][1][1] }, $^R->[1];
                                  $^R->[0];
                              })
                          )*
                      )?
                      \s*\)\s*
                  )?
              )

              (?<ATTR_SUBJECTS>
                  (?{ [$^R, []] })
                  (?&ATTR_SUBJECT)
                  (?{
                      push @{ $^R->[0][1] }, {
                          name => $^R->[1][0],
                          (args => $^R->[1][1]) x !!defined($^R->[1][1]),
                      };
                      $^R->[0];
                  })
              )

              (?<LITERAL_NUMBER>
                  (
                      -?
                      (?: 0 | [1-9]\d* )
                      (?: \. \d+ )?
                      (?: [eE] [-+]? \d+ )?
                  )
                  (?{ [$^R, 0+$^N] })
              )

          ) # DEFINE
  }x;

sub parse_csel {
    state $re = qr{\A\s*$RE\s*\z};

    local $_ = shift;
    local $^R;
    eval { $_ =~ $re } and return $_;
    die $@ if $@;
    return undef;
}

1;
