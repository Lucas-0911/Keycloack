<#import "template.ftl" as layout>
<@layout.emailLayout>
    <h2 style="margin-top: 0; color: #0f172a;">Link your account</h2>
    <p>Hi ${user.firstName!user.username!'there'},</p>
    <p>We received a request to link your Flash DTF account with your <strong>${identityProviderAlias}</strong> account.</p>
    
    <div style="background-color: #f8fafc; border-left: 4px solid #0ea5e9; padding: 15px; margin: 20px 0;">
        <strong>If you initiated this request, click the button below to confirm.</strong>
    </div>

    <p>This link will expire in ${linkExpiration} minutes.</p>

    <div class="btn-container">
        <a href="${link}" class="btn">Confirm Account Link</a>
    </div>
    
    <p class="muted-text">If you did not request to link these accounts, you can safely ignore this email.</p>
    <p class="muted-text" style="word-break: break-all; margin-top: 40px; font-size: 12px;">
        Or copy and paste this link into your browser:<br>
        <a href="${link}" style="color: #0ea5e9;">${link}</a>
    </p>
</@layout.emailLayout>
