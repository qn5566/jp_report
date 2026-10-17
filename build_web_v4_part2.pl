#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
binmode(STDOUT, ":utf8");
use File::Copy qw(copy);
use File::Basename qw(dirname);
use FindBin qw($Bin);

my $source_part2 = "$Bin/generate_v3_part2.pl";
my $target = "$Bin/app/index.html";
my $copy1 = "$Bin/../japan-go-app/app/index.html";
my $copy2 = "$Bin/japan_sakura_app_design_preview.html";

open my $in, '<:utf8', $source_part2 or die "Cannot open $source_part2: $!\n";
my $content = do { local $/; <$in> };
close $in;

# Extract the heredoc section: from JS_CODE_SECTION to JS_CODE_SECTION
if ($content =~ /print \$fh <<'JS_CODE_SECTION';\n([\s\S]+?)\nJS_CODE_SECTION/) {
    my $js_section = $1;
    
    # Enhance updateBookmarkBadge to support floating and footer badges
    my $old_badge_func = 'function updateBookmarkBadge() {
      const badge = document.getElementById(\'bookmark-badge\');
      const count = bookmarkedIds.length;
      document.getElementById(\'drawer-count\').textContent = count;
      if (count > 0) {
        badge.textContent = count;
        badge.classList.remove(\'hidden\');
      } else {
        badge.classList.add(\'hidden\');
      }
    }';

    my $new_badge_func = 'function updateBookmarkBadge() {
      const badge = document.getElementById(\'bookmark-badge\');
      const count = bookmarkedIds.length;
      const drawerCount = document.getElementById(\'drawer-count\');
      if (drawerCount) drawerCount.textContent = count;
      const floatingBadge = document.getElementById(\'floating-fav-badge\');
      if (floatingBadge) floatingBadge.textContent = count;
      const footerCount = document.getElementById(\'footer-fav-count\');
      if (footerCount) footerCount.textContent = count;
      if (badge) {
        if (count > 0) {
          badge.textContent = count;
          badge.classList.remove(\'hidden\');
        } else {
          badge.classList.add(\'hidden\');
        }
      }
    }';

    $js_section =~ s/\Q$old_badge_func\E/$new_badge_func/;

    open my $out, '>>:utf8', $target or die "Cannot append to $target: $!\n";
    print $out $js_section;
    close $out;

    if (-d dirname($copy1)) {
        copy($target, $copy1) or warn "Copy to $copy1 failed: $!\n";
        print "Copy 1: $copy1 (" . (-s $copy1) . " bytes)\n";
    }
    if (-d dirname($copy2)) {
        copy($target, $copy2) or warn "Copy to $copy2 failed: $!\n";
        print "Copy 2: $copy2 (" . (-s $copy2) . " bytes)\n";
    }

    print "Web V4 built successfully!\n";
    print "Target file: $target (" . (-s $target) . " bytes)\n";
} else {
    die "Could not find JS_CODE_SECTION in $source_part2\n";
}

