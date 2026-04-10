<#import "template.ftl" as layout>
<@layout.emailLayout>
    <h2 style="margin-top: 0; color: #0f172a;">Password Reset Request</h2>
    <p>Hi ${user.firstName!user.username!'there'},</p>
    <p>We received a request to reset the password for your Flash DTF account. Click the button below to choose a new password. This link will expire in ${linkExpiration} minutes.</p>
    
    <div class="btn-container">
        <a href="${link}" class="btn">Reset Password</a>
    </div>
    
    <p class="muted-text">If you didn't request a password reset, you can safely ignore this email. Your current password will remain unchanged.</p>
    <p class="muted-text" style="word-break: break-all; margin-top: 40px; font-size: 12px;">
        Or copy and paste this link into your browser:<br>
        <a href="${link}" style="color: #0ea5e9;">${link}</a>
    </p>
</@layout.emailLayout>
