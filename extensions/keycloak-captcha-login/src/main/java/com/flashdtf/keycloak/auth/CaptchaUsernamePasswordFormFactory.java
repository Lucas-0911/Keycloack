package com.flashdtf.keycloak.auth;

import org.keycloak.authentication.Authenticator;
import org.keycloak.authentication.authenticators.browser.UsernamePasswordFormFactory;
import org.keycloak.models.KeycloakSession;
import org.keycloak.provider.ProviderConfigProperty;

import java.util.ArrayList;
import java.util.List;

public class CaptchaUsernamePasswordFormFactory extends UsernamePasswordFormFactory {

    public static final String PROVIDER_ID = "auth-conditional-captcha-form";
    public static final CaptchaUsernamePasswordForm SINGLETON = new CaptchaUsernamePasswordForm();

    @Override
    public String getDisplayType() {
        return "Conditional Captcha Username Password Form";
    }

    @Override
    public String getHelpText() {
        return "Validates username and password. Requires Google reCAPTCHA validation after 3 failed attempts.";
    }

    @Override
    public List<ProviderConfigProperty> getConfigProperties() {
        List<ProviderConfigProperty> props = new ArrayList<>();
        
        ProviderConfigProperty siteKey = new ProviderConfigProperty();
        siteKey.setType(ProviderConfigProperty.STRING_TYPE);
        siteKey.setName("site.key");
        siteKey.setLabel("reCAPTCHA Site Key");
        siteKey.setHelpText("Google reCAPTCHA v2 Site Key");
        props.add(siteKey);

        ProviderConfigProperty secret = new ProviderConfigProperty();
        secret.setType(ProviderConfigProperty.STRING_TYPE);
        secret.setName("secret");
        secret.setLabel("reCAPTCHA Secret");
        secret.setHelpText("Google reCAPTCHA v2 Secret Key");
        props.add(secret);

        return props;
    }

    @Override
    public Authenticator create(KeycloakSession session) {
        return SINGLETON;
    }

    @Override
    public Authenticator createDisplay(KeycloakSession session, String displayType) {
        if (displayType == null) return SINGLETON;
        if (!org.keycloak.OAuth2Constants.DISPLAY_CONSOLE.equalsIgnoreCase(displayType)) return null;
        return org.keycloak.authentication.authenticators.browser.ConsoleUsernamePasswordAuthenticator.SINGLETON;
    }

    @Override
    public String getId() {
        return PROVIDER_ID;
    }
}
