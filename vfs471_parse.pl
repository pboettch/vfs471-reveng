sub frame_processor($$)
{
	my %req = %{ $_[0] };
	my %resp = %{ $_[1] };

	if ($resp{TransferType} == 2) {
		print "ctrl ";
	} elsif ($resp{TransferType} == 3) {
		print "bulk ";
	} elsif ($resp{TransferType} == 1) {
		print "intr ";
	} else {
		die "unkown $resp{TransferType}";
	}

	my $out = $resp{Endpoint} < 0x80;
	if ($out) {
		print "out ";
	} else {
		print "in  ";
	}
	my $ep = $resp{Endpoint} & 0x7f;
	printf "%02x ", $ep;

	if ($resp{TransferType} == 2) {
# display setup
	}

	printf "(%5d %5d) ", $req{PayloadSize}, $resp{PayloadSize};

	my $handled = 0;
	if ($out) {
		if ($ep == 1) {
			handle_ep1_out(substr($req{Payload}, 48), $req{PayloadSize} - 24);
			$handled = 1;
		}
	} else {
		if ($ep == 1) {
			handle_ep1_in(substr($resp{Payload}, 48), $resp{PayloadSize} - 24);
			$handled = 1;
		} elsif ($ep == 2) {
			handle_ep2_in(substr($resp{Payload}, 48), $resp{PayloadSize}-24);
			$handled = 1;
		}
	}

	if (!$handled) {
		print substr($req{Payload}, 48, 48), " : ";
		print substr($resp{Payload}, 48, 48);
	}
	print "\n";
}

sub handle_ep1_out($$)
{
	my @d = shift =~ /(..)/g;
	my $length = shift;
	if ($d[0] eq "17" and $d[1] eq "03" and $d[2] eq "00") {
		handle_1703(@d);
	} else {
		print "req $d[0] unhandled (",scalar @d,") : ", join(" ", @d);
	}
}

sub handle_ep1_in($$)
{
	my @d = shift =~ /(..)/g;
	my $length = shift;
	if ($d[0] eq "17" and $d[1] eq "03" and $d[2] eq "00") {
		handle_1703(@d);
	} else {
		print "req $d[0] unhandled (",scalar @d,")", join(" ", @d);
	}
}

sub handle_1703($)
{
	my $len = hex($_[3]) * 256 + hex($_[4]);
	print "req 170300: $len bytes data (5 + $len = ", scalar @_,"): ", join(" ", @_);
}

sub handle_ep2_in($$)
{
	my @d = shift =~ /(..)/g;
	my $length = shift;

	print " $length: ";
#if ($length == 64) {
		print join(" ", @d);
#	}
}

1;
