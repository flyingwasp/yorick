# -*-perl-*-
# texi2html homepage:
# http://www.mathematik.uni-kl.de/~obachman/Texi2html
# texi2html -init_file texi2html.init yorick.tex

$print_page_foot	      = \&no_print_page_foot;        
$ICONS = 1;
$SPLIT = 'node';

$EXTRA_HEAD = <<'EOF';
%extra_head%
EOF

$AFTER_BODY_OPEN = <<'EOF';
%after_body_open%
EOF

$PRE_BODY_CLOSE = <<'EOF';
%pre_body_close%
EOF

# specify in this array which "buttons" should appear in which order
# in the navigation panel for sections; use ' ' for empty buttons (space)
@SECTION_BUTTONS =
    (
     'Back', 'Forward', ' ', 'FastBack', 'Up', 'FastForward',
     ' ', ' ', ' ', ' ',
     'Top', 'Contents', 'About',
    );

# buttons for misc stuff
@MISC_BUTTONS = ('Top', 'Contents', 'About');

@NODE_FOOTER_BUTTONS =
    (
     'Back', 'Forward', ' ', 'FastBack', 'Up', 'FastForward',
     ' ', ' ', ' ', ' ',
     'Top', 'Contents', 'About',
#     'Back', 'Forward', ' ', 'FastBack', 'Up', 'FastForward'
    );

# insert here name of icon images for buttons 
# Icons are used, if $ICONS and resp. value are set
%ACTIVE_ICONS =
  (
   'Top',      '../images/a_top.gif',
   'Contents', '../images/a_tableofcon.gif',
   'Overview', '',
   'Index',    '../images/a_index.gif',
   'Back',     '../images/a_left.gif',
   'FastBack', '../images/a_leftdouble.gif',
   'Prev',     '../images/a_left.gif',
   'Up',       '../images/a_up.gif',
   'Next',     '../images/a_right.gif',
   'Forward',  '../images/a_right.gif',
   'FastForward', '../images/a_rightdouble.gif',
   'About' ,    '../images/a_help.gif',
   'First',    '../images/a_begin.gif',
   'Last',     '../images/a_end.gif',
   ' ',        ''
  );
%PASSIVE_ICONS =
  (
   'Top',      '../images/a_top_na.gif',
   'Contents', '../images/a_tableofcon_na.gif',
   'Overview', '',
   'Index',    '../images/a_index_na.gif',
   'Back',     '../images/a_left_na.gif',
   'FastBack', '../images/a_leftdouble_na.gif',
   'Prev',     '../images/a_left_na.gif',
   'Up',       '../images/a_up_na.gif',
   'Next',     '../images/a_right_na.gif',
   'Forward',  '../images/a_right_na.gif',
   'FastForward', '../images/a_rightdouble_na.gif',
   'About' ,    '../images/a_help_na.gif',
   'First',    '../images/a_begin_na.gif',
   'Last',     '../images/a_end_na.gif',
   ' ',        ''
  );

sub no_print_page_foot
{
  my $fh = shift;
  print $fh <<EOT;
$PRE_BODY_CLOSE
</BODY>
</HTML>
EOT
}

$copying_comment          = \&my_copying_comment;
sub my_copying_comment($)
{
    return '';
}

# rewrite print_navigation to get rid of #SEC12 anchor references
# they cause page to be centered on navigation bar instead of top
sub my_strip_href($)
{
    my $x = shift;
    $x =~ s/#.*$//;
    return $x;
}

$print_navigation = \&my_print_navigation;

sub my_print_navigation($$$)
{
    my $fh = shift;
    my $buttons = shift;
    my $vertical = shift;
    my $spacing = 1;
    print $fh '<table cellpadding="', $spacing, '" cellspacing="', $spacing,
      "\" border=\"0\"><tbody>\n";

    print $fh "<tr>" unless $vertical;
    for my $button (@$buttons)
    {
        print $fh qq{<tr valign="top" align="left">\n} if $vertical;
        print $fh qq{<td valign="middle" align="left">};

        if (ref($button) eq 'CODE')
        {
            &$button($fh, $vertical);
        }
        elsif (ref($button) eq 'SCALAR')
        {
            print $fh "$$button" if defined($$button);
        }
        elsif (ref($button) eq 'ARRAY')
        {
            my $text = $button->[1];
            my $button_href = $button->[0];
            if (defined($button_href) and !ref($button_href) 
               and defined($text) and (ref($text) eq 'SCALAR') and defined($$text))
            {             # use given text
		my $btn_hr = $Texi2HTML::HREF{$button_href};
                if ($btn_hr)
                {
                  print $fh "" .
                        &$anchor('',
                                    my_strip_href($btn_hr),
                                    $$text
                                   ) 
                                    ;
                }
                else
                {
                  print $fh $$text;
                }
            }
        }
        elsif ($button eq ' ')
        {                       # handle space button
            print $fh
                $ICONS && $ACTIVE_ICONS{' '} ?
                    &$button_icon_img($button, $ACTIVE_ICONS{' '}) :
                        $NAVIGATION_TEXT{' '};
            #next;
        }
        elsif ($Texi2HTML::HREF{$button})
        {                       # button is active
	    my $btn_hr = $Texi2HTML::HREF{$button};
            my $btitle = $BUTTONS_GOTO{$button} ?
                'title="' . ucfirst($BUTTONS_GOTO{$button}) . '"' : '';
            if ($ICONS && $ACTIVE_ICONS{$button})
            {                   # use icon
                print $fh '' .
                    &$anchor('',
                        my_strip_href($btn_hr),
                        &$button_icon_img($button,
                                   $ACTIVE_ICONS{$button},
                                   #$Texi2HTML::NAME{$button}),
                                   $Texi2HTML::NO_TEXI{$button}),
                        $btitle
                      );
            }
            else
            {                   # use text
                print $fh
                    '[' .
                        &$anchor('',
                                    my_strip_href($btn_hr),
                                    $NAVIGATION_TEXT{$button},
                                    $btitle
                                   ) .
                                       ']';
            }
        }
        else
        {                       # button is passive
            print $fh
                $ICONS && $PASSIVE_ICONS{$button} ?
                    &$button_icon_img($button,
                                          $PASSIVE_ICONS{$button},
                                          #$Texi2HTML::NAME{$button}) :
                                          $Texi2HTML::NO_TEXI{$button}) :

                                              "[" . $NAVIGATION_TEXT{$button} . "]";
        }
        print $fh "</td>\n";
        print $fh "</tr>\n" if $vertical;
    }
    print $fh "</tr>" unless $vertical;
    print $fh "</tbody></table>\n";
}

1;	# This must be the last non-comment line