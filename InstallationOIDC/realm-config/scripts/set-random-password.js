/*
Available objects in the script:
 - user, userStorage, realm, session, authenticationSession, httpRequest, context
 - Also Java.type(...) for Java classes
*/
var RandomString = Java.type("org.keycloak.common.util.RandomString");
var PasswordCredentialModel = Java.type("org.keycloak.models.credential.PasswordCredentialModel");

function authenticate(context) {
    var user = context.getUser();
    if (!user) {
        context.attempted();
        return;
    }

    var randomPassword = RandomString.randomCode(12); // 12 char random pwd

    var credential = PasswordCredentialModel.createFromValues(randomPassword, false);

    session.userCredentialManager().updateCredential(realm, user, credential);

    // Optionally log it (not recommended in production):
    // print("Assigned random LDAP password: " + randomPassword);

    context.success();
}

function action(context) {
    // Not used in this simple example
}

function requiresUser() {
    return true;
}

function configuredFor(context, user) {
    return false;
}

function setRequiredActions(context, user) {
    // No additional required actions
}

function close() {
    // no-op
}
