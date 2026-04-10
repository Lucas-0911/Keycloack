<#import "template.ftl" as layout>
<@layout.emailLayout>
    <h2 style="margin-top: 0; color: #0f172a;">Verify your email address</h2>
    <p>Hi ${user.firstName!user.username!'there'},</p>
    <p>Thanks for creating an account with Flash DTF! Please click the button below to verify your email address and activate your account. This link will expire in ${linkExpiration} minutes.</p>
    
    <div class="btn-container">
        <a href="${link}" class="btn">Verify Email Address</a>
    </div>
    
    <p class="muted-text">If you didn't request this, you can safely ignore this email.</p>
    <p class="muted-text" style="word-break: break-all; margin-top: 40px; font-size: 12px;">
        Or copy and paste this link into your browser:<br>
        <a href="${link}" style="color: #0ea5e9;">${link}</a>
    </p>
</@layout.emailLayout>
