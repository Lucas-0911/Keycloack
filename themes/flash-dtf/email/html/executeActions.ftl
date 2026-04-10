<#import "template.ftl" as layout>
<@layout.emailLayout>
    <h2 style="margin-top: 0; color: #0f172a;">Action Required</h2>
    <p>Hi ${user.firstName!user.username!'there'},</p>
    <p>Your administrator has requested that you perform the following action(s) for your Flash DTF account:</p>
    
    <div style="background-color: #f8fafc; border-left: 4px solid #0ea5e9; padding: 15px; margin: 20px 0;">
        <#-- Keycloak converts the requiredAction list into readable messages internally, but here we can just say "Update your account details" -->
        <strong>Please update your account credentials/settings.</strong>
    </div>

    <p>Click the button below to proceed. This link will expire in ${linkExpiration} minutes.</p>

    <div class="btn-container">
        <a href="${link}" class="btn">Update Account</a>
    </div>
    
    <p class="muted-text">If you are unaware of this request, please contact your administrator.</p>
    <p class="muted-text" style="word-break: break-all; margin-top: 40px; font-size: 12px;">
        Or copy and paste this link into your browser:<br>
        <a href="${link}" style="color: #0ea5e9;">${link}</a>
    </p>
</@layout.emailLayout>
