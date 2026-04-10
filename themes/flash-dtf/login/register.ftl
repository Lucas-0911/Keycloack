<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('email','password','password-confirm') displayInfo=true; section>
    <#if section = "form">
        <form id="kc-register-form" class="flash-dtf-register-form" action="${url.registrationAction}" method="post">

            <#-- Email field -->
            <div class="flash-dtf-field">
                <label for="email" class="flash-dtf-label">Email</label>
                <div class="flash-dtf-input-wrapper">
                    <input type="email" id="email" name="email"
                           value="${(register.formData.email!'')}"
                           class="flash-dtf-input <#if messagesPerField.existsError('email')>flash-dtf-input-error</#if>"
                           autocomplete="email"
                           placeholder="Enter your email"
                           autofocus
                           aria-invalid="<#if messagesPerField.existsError('email')>true</#if>"
                    />
                </div>
                <#if messagesPerField.existsError('email')>
                    <div class="flash-dtf-field-error" aria-live="polite">
                        ${kcSanitize(messagesPerField.getFirstError('email'))?no_esc}
                    </div>
                </#if>
            </div>

            <#-- Hidden username = email (Keycloak requires username) -->
            <input type="hidden" id="username" name="username" value="${(register.formData.username!'')}" />

            <#-- Password field -->
            <div class="flash-dtf-field">
                <label for="password" class="flash-dtf-label">Password</label>
                <div class="flash-dtf-input-wrapper flash-dtf-password-wrapper">
                    <input type="password" id="password" name="password"
                           autocomplete="new-password"
                           class="flash-dtf-input <#if messagesPerField.existsError('password','password-confirm')>flash-dtf-input-error</#if>"
                           placeholder="Enter your password"
                           aria-invalid="<#if messagesPerField.existsError('password','password-confirm')>true</#if>"
                    />
                    <button type="button" class="flash-dtf-toggle-password" onclick="togglePassword('password')" aria-label="Toggle password visibility">
                        <svg class="eye-icon" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#999" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/>
                            <line x1="1" y1="1" x2="23" y2="23"/>
                        </svg>
                    </button>
                </div>
                <#if messagesPerField.existsError('password')>
                    <div class="flash-dtf-field-error" aria-live="polite">
                        ${kcSanitize(messagesPerField.getFirstError('password'))?no_esc}
                    </div>
                </#if>
            </div>

            <#-- Confirm Password (hidden, auto-synced via JS) -->
            <input type="hidden" id="password-confirm" name="password-confirm" />

            <#-- Sign up button -->
            <div class="flash-dtf-submit">
                <button class="flash-dtf-btn flash-dtf-btn-primary" type="submit">
                    Sign up
                </button>
            </div>

            <#-- Social login - always visible -->
            <div class="flash-dtf-separator">
                <span>or continue with</span>
            </div>
            <div class="flash-dtf-social-buttons">
                <#if realm.password && social?? && social.providers?has_content>
                    <#list social.providers as p>
                        <a id="social-${p.alias}" class="flash-dtf-social-btn" href="${p.loginUrl}">
                            <#if p.alias == "google">
                                <img src="${url.resourcesPath}/img/google-icon.svg" alt="Google" width="24" height="24" />
                            <#elseif p.alias == "apple">
                                <img src="${url.resourcesPath}/img/apple-icon.svg" alt="Apple" width="24" height="24" />
                            <#else>
                                <#if p.iconClasses?has_content>
                                    <i class="${p.iconClasses!}" aria-hidden="true"></i>
                                </#if>
                                <span>${p.displayName!}</span>
                            </#if>
                        </a>
                    </#list>
                <#else>
                    <#-- Static Google & Apple buttons (shown when IdP not yet configured) -->
                    <a class="flash-dtf-social-btn" href="#" onclick="return false;" title="Google (not configured)">
                        <img src="${url.resourcesPath}/img/google-icon.svg" alt="Google" width="24" height="24" />
                    </a>
                    <a class="flash-dtf-social-btn" href="#" onclick="return false;" title="Apple (not configured)">
                        <img src="${url.resourcesPath}/img/apple-icon.svg" alt="Apple" width="24" height="24" />
                    </a>
                </#if>
            </div>
        </form>

    <#elseif section = "info">
        <div class="flash-dtf-register-link">
            Already have an account? <a href="${url.loginUrl}">Sign in</a>
        </div>
    </#if>
</@layout.registrationLayout>

<script>
    function togglePassword(inputId) {
        var input = document.getElementById(inputId);
        if (input.type === 'password') {
            input.type = 'text';
        } else {
            input.type = 'password';
        }
    }

    // Auto-sync email → username and password → password-confirm
    document.addEventListener('DOMContentLoaded', function() {
        var emailInput = document.getElementById('email');
        var usernameInput = document.getElementById('username');
        var passwordInput = document.getElementById('password');
        var confirmInput = document.getElementById('password-confirm');

        if (emailInput && usernameInput) {
            emailInput.addEventListener('input', function() {
                var email = emailInput.value;
                if (email && email.indexOf('@') > -1) {
                    usernameInput.value = email.split('@')[0];
                } else {
                    usernameInput.value = email;
                }
            });
        }
        if (passwordInput && confirmInput) {
            passwordInput.addEventListener('input', function() {
                confirmInput.value = passwordInput.value;
            });
        }
    });
</script>
