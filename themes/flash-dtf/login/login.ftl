<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','password') displayInfo=realm.password && realm.registrationAllowed && !registrationDisabled??; section>
    <#if section = "form">
        <div id="kc-form">
            <div id="kc-form-wrapper">
                <#if realm.password>
                    <form id="kc-form-login" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post">

                        <#-- Email field -->
                        <div class="flash-dtf-field">
                            <label for="username" class="flash-dtf-label">Email</label>
                            <div class="flash-dtf-input-wrapper">
                                <input tabindex="1" id="username" name="username" type="text"
                                       autofocus autocomplete="username"
                                       placeholder="Enter your email"
                                       class="flash-dtf-input"
                                       aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"
                                       value="${(login.username!'')}"
                                />
                            </div>
                        </div>

                        <#-- Password field -->
                        <div class="flash-dtf-field">
                            <label for="password" class="flash-dtf-label">Password</label>
                            <div class="flash-dtf-input-wrapper flash-dtf-password-wrapper">
                                <input tabindex="2" id="password" name="password" type="password"
                                       autocomplete="current-password"
                                       placeholder="Enter your password"
                                       class="flash-dtf-input"
                                       aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"
                                />
                                <button type="button" class="flash-dtf-toggle-password" onclick="togglePassword('password')" tabindex="5" aria-label="Toggle password visibility">
                                    <svg class="eye-icon" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#999" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/>
                                        <line x1="1" y1="1" x2="23" y2="23"/>
                                    </svg>
                                </button>
                            </div>
                            <#if realm.resetPasswordAllowed>
                                <div class="flash-dtf-forgot-password">
                                    <a tabindex="4" href="${url.loginResetCredentialsUrl}">Forgot password?</a>
                                </div>
                            </#if>
                        </div>

                        <#-- Error message -->
                        <#if messagesPerField.existsError('username','password')>
                            <div class="flash-dtf-field-error" aria-live="polite">
                                ${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}
                            </div>
                        </#if>

                        <#-- Remember me -->
                        <#if realm.rememberMe && !usernameHidden??>
                            <div class="flash-dtf-remember-me">
                                <label>
                                    <#if login.rememberMe??>
                                        <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox" checked>
                                    <#else>
                                        <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox">
                                    </#if>
                                    <span>${msg("rememberMe")}</span>
                                </label>
                            </div>
                        </#if>

                        <#-- reCAPTCHA -->
                        <#if captchaRequired?? && captchaRequired>
                            <div class="flash-dtf-field" style="margin-top: 20px; display: flex; justify-content: center;">
                                <div class="g-recaptcha" data-sitekey="${recaptchaSiteKey}"></div>
                            </div>
                            <script src="https://www.google.com/recaptcha/api.js" async defer></script>
                        </#if>

                        <#-- Sign in button -->
                        <div class="flash-dtf-submit">
                            <input type="hidden" id="id-hidden-input" name="credentialId" <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>
                            <button tabindex="3" class="flash-dtf-btn flash-dtf-btn-primary" name="login" id="kc-login" type="submit">
                                Sign in
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
                </#if>
            </div>
        </div>

    <#elseif section = "info">
        <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
            <div class="flash-dtf-register-link">
                Don't have account? <a tabindex="6" href="${url.registrationUrl}">Sign up</a>
            </div>
        </#if>
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
</script>
