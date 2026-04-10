package com.flashdtf.keycloak.auth;

import jakarta.ws.rs.core.MultivaluedMap;
import jakarta.ws.rs.core.Response;
import org.jboss.logging.Logger;
import org.keycloak.authentication.AuthenticationFlowContext;
import org.keycloak.authentication.AuthenticationFlowError;
import org.keycloak.authentication.authenticators.browser.UsernamePasswordForm;
import org.keycloak.forms.login.LoginFormsProvider;
import org.keycloak.models.AuthenticatorConfigModel;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;

public class CaptchaUsernamePasswordForm extends UsernamePasswordForm {

    private static final Logger logger = Logger.getLogger(CaptchaUsernamePasswordForm.class);
    protected static final String FAILED_ATTEMPTS_NOTE = "failed_login_attempts";
    
    // Default thresholds, could be configured in AuthenticatorConfig
    protected static final int CAPTCHA_THRESHOLD = 3; 

    @Override
    public void authenticate(AuthenticationFlowContext context) {
        if (isCaptchaRequired(context)) {
            context.form().setAttribute("captchaRequired", true);
            context.form().setAttribute("recaptchaSiteKey", getRecaptchaSiteKey(context));
        }
        super.authenticate(context);
    }

    @Override
    public void action(AuthenticationFlowContext context) {
        MultivaluedMap<String, String> formData = context.getHttpRequest().getDecodedFormParameters();
        
        if (isCaptchaRequired(context)) {
            String captchaResponse = formData.getFirst("g-recaptcha-response");
            if (captchaResponse == null || captchaResponse.trim().isEmpty() || !validateRecaptcha(context, captchaResponse)) {
                // Invalid captcha
                Response challenge = context.form()
                        .setAttribute("captchaRequired", true)
                        .setAttribute("recaptchaSiteKey", getRecaptchaSiteKey(context))
                        .setError("Mã bảo vệ (CAPTCHA) không hợp lệ hoặc đã hết hạn. Vui lòng thử lại.")
                        .createLoginUsernamePassword();
                context.challenge(challenge);
                return;
            }
        }

        // Proceed with normal username/password validation
        super.action(context);

        // Check outcome
        if (context.getStatus() != null && (context.getStatus().name().contains("CHALLENGE") || context.getStatus().name().contains("FAILURE"))) {
            int failedAttempts = getFailedAttempts(context) + 1;
            context.getAuthenticationSession().setAuthNote(FAILED_ATTEMPTS_NOTE, String.valueOf(failedAttempts));
            
            // If it just reached the threshold, we need to inject the captcha flag into the challenge response
            if (failedAttempts >= CAPTCHA_THRESHOLD) {
                Response challenge = context.form()
                        .setAttribute("captchaRequired", true)
                        .setAttribute("recaptchaSiteKey", getRecaptchaSiteKey(context))
                        .setError("Nhập sai quá nhiều lần. Vui lòng xác nhận bạn không phải robot.")
                        .createLoginUsernamePassword();
                context.challenge(challenge);
            }
        } else if (context.getStatus() != null && context.getStatus().name().equals("SUCCESS")) {
            // Reset counter on success
            context.getAuthenticationSession().removeAuthNote(FAILED_ATTEMPTS_NOTE);
        }
    }

    private boolean isCaptchaRequired(AuthenticationFlowContext context) {
        return getFailedAttempts(context) >= CAPTCHA_THRESHOLD;
    }

    private int getFailedAttempts(AuthenticationFlowContext context) {
        String attemptsStr = context.getAuthenticationSession().getAuthNote(FAILED_ATTEMPTS_NOTE);
        if (attemptsStr != null) {
            try {
                return Integer.parseInt(attemptsStr);
            } catch (NumberFormatException e) {
                // Ignore
            }
        }
        return 0;
    }

    private String getRecaptchaSiteKey(AuthenticationFlowContext context) {
        AuthenticatorConfigModel config = context.getAuthenticatorConfig();
        if (config != null && config.getConfig() != null) {
            return config.getConfig().get("site.key");
        }
        return "YOUR_RECAPTCHA_SITE_KEY_HERE"; // Fallback or setup via config
    }

    private String getRecaptchaSecret(AuthenticationFlowContext context) {
        AuthenticatorConfigModel config = context.getAuthenticatorConfig();
        if (config != null && config.getConfig() != null) {
            return config.getConfig().get("secret");
        }
        return "YOUR_RECAPTCHA_SECRET_HERE"; // Fallback or setup via config
    }

    private boolean validateRecaptcha(AuthenticationFlowContext context, String captchaResponse) {
        String secret = getRecaptchaSecret(context);
        try {
            HttpClient client = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(5))
                    .build();
            
            String requestBody = "secret=" + secret + "&response=" + captchaResponse;
            
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://www.google.com/recaptcha/api/siteverify"))
                    .header("Content-Type", "application/x-www-form-urlencoded")
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                    .build();
                    
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            
            // Very naive check for "success": true
            return response.body().contains("\"success\": true");
            
        } catch (Exception e) {
            logger.error("Error validating reCAPTCHA", e);
            return false;
        }
    }
}
