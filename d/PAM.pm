#This is a dummy file so CPAN will find a VERSION
package Authen::PAM;
$VERSION = "0.08";
#This is to make sure require will return an error
0;
__END__

=head1 NAME

Authen::PAM - Perl interface to PAM library

=head1 SYNOPSIS

  use Authen::PAM;

  $retval = pam_start($service_name, $user, $pamh);
  $retval = pam_start($service_name, $user, $conv_func, $pamh);
  $retval = pam_end($pamh, $pam_status);

  $retval = pam_authenticate($pamh, $flags);
  $retval = pam_setcred($pamh, $flags);
  $retval = pam_acct_mgmt($pamh, $flags);
  $retval = pam_open_session($pamh, $flags);
  $retval = pam_close_session($pamh, $flags);
  $retval = pam_chauthtok($pamh, $flags);

  $error_str = pam_strerror($pamh, $errnum);

  $retval = pam_set_item($pamh, $item_type, $item);
  $retval = pam_get_item($pamh, $item_type, $item);

  if (HAVE_PAM_ENV_FUNCTIONS) {
      $retval = pam_putenv($pamh, $name_value);
      $val = pam_getenv($pamh, $name);
      %env = pam_getenvlist($pamh);
  }

  if (HAVE_PAM_FAIL_DELAY) {
      $retval = pam_fail_delay($pamh, $musec_delay);
  }

=head1 DESCRIPTION

The I<Authen::PAM> module provides a Perl interface to the I<PAM>
library. The only difference with the standard PAM interface is that
instead of passing a pam_conv struct which has an additional
context parameter appdata_ptr, you must only give an address to a
conversation function written in Perl (see below).
If you use the 3 argument version of pam_start then a default conversation
function is used (Authen::PAM::pam_default_conv).

The $flags argument is optional for all functions which use it
except for pam_setcred. The $pam_status argument is also optional for
pam_end function. Both of this arguments will be set to 0 if not given.

The names of some constants from the PAM library have changed over the
time. You can use any of the known names for a given constant although
it is advisable to use the latest one.

When this module supports some of the additional features of the PAM
library (e.g. pam_fail_delay) then the corresponding HAVE_PAM_XXX
constant will have a value 1 otherwise it will return 0.

For compatibility with older PAM libraries I have added the constant
HAVE_PAM_ENV_FUNCTIONS which is true if your PAM library has the set
of functions for handling the environment variables (pam_putenv, pam_getenv,
pam_getenvlist).


=head2 Object Oriented Style

If you prefer to use an object oriented style for accessing the PAM
library here is the interface:

  $pamh = new Authen::PAM($service_name, $user);
  $pamh = new Authen::PAM($service_name, $user, $conv_func);

  $retval = $pamh->pam_authenticate($flags);
  $retval = $pamh->pam_setcred($flags);
  $retval = $pamh->pam_acct_mgmt($flags);
  $retval = $pamh->pam_open_session($flags);
  $retval = $pamh->pam_close_session($flags);
  $retval = $pamh->pam_chauthtok($flags);

  $error_str = $pamh->pam_strerror($errnum);

  $retval = $pamh->pam_set_item($item_type, $item);
  $retval = $pamh->pam_get_item($item_type, $item);

  $retval = $pamh->pam_putenv($name_value);
  $val = $pamh->pam_getenv($name);
  %env = $pamh->pam_getenvlist;

The constructor new will call the pam_start function and if successfull
will return an object reference. Otherwise the $pamh will contain the
error number returned by pam_start.
The pam_end function will be called automatically when the object is no
longer referenced.

=head2 Examples

Here is an example of using PAM for changing the password of the current
user:

  use Authen::PAM;

  $login_name = getpwuid($<);

  pam_start("passwd", $login_name, $pamh);
  pam_chauthtok($pamh);
  pam_end($pamh);


or the same thing but using OO style:

  $pamh = new Authen::PAM("passwd", $login_name);
  $pamh->pam_chauthtok;
  $pamh = 0;  # Force perl to call the destructor for the $pamh

=head2 Conversation function format

When starting the PAM the user must supply a conversation function.
It is used for interaction between the PAM modules and the user.
The argument of the function is a list of pairs ($msg_type, $msg)
and it must return a list with the same number of pairs ($resp_retcode, $resp)
with replies to the input messages. For now the $resp_retcode is not used
and must be always set to 0.  In addition the user must append to
the end of the resulting list the return code of the conversation function
(usually PAM_SUCCESS).

Here is a sample form of the PAM conversation function:

sub pam_conv_func {
    my @res;
    while ( @_ ) {
        my $msg_type = shift;
        my $msg = shift;

        print $msg;

	# switch ($msg_type) { obtain value for $ans; }

        push @res, 0;
        push @res, $ans;
    }
    push @res, PAM_SUCCESS;
    return @res;
}


=head1 COMPATIBILITY

This module was tested with the following versions of the Linux-PAM library:
0.50, 0.56, 0.59 and 0.65.

This module still does not support some of the new Linux-PAM
functions such as pam_system_log.

=head1 SEE ALSO

PAM Application developer's Manual

=head1 AUTHOR

Nikolay Pelov <nikip@iname.com>

=cut
