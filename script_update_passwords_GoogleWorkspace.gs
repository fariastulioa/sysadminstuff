// This script will update users passwords to a default one, provided through the script itself to senha_padrao variable.
// Every user whose email is given to the listaEmails variable will have their password changed to the default one.
// The script also forces the option/flag changePasswordAtNextLogin to 'true', forcing them to change their passwords at 1st login
// In order to make sure accounts can be accessed by the users, all of them are set to be unsuspended

// Requirements:
//  This script is to be run at https://scripts.google.com
//  Under "Services", AdminDirectory SDK needs to be enabled/added to the script
//  No libraries are needed for this to work

function do_password_updates() {
  Logger.log("Starting Script...");
  var senha_padrao = "4L3N3UvdaZ!@#";

  var lista_emails = [
  
  ];



  for (index = 0; index < lista_emails.length; index++) {
    
    var email = lista_emails[index];
    var usuario = AdminDirectory.Users.get(email);

    usuario.password = senha_padrao;
    Logger.log(usuario.changePasswordAtNextLogin)

    usuario.changePasswordAtNextLogin = true;
    Logger.log(usuario.changePasswordAtNextLogin)

    usuario.suspended = false;

    AdminDirectory.Users.update(usuario, email);

  }


}