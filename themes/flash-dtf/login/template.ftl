<#macro registrationLayout bodyClass="" displayInfo=false displayMessage=true displayRequiredFields=false>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="robots" content="noindex, nofollow">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <#if properties.meta?has_content>
        <#list properties.meta?split(' ') as meta>
            <meta name="${meta?keep_before('=')}" content="${meta?keep_after('=')}"/>
        </#list>
    </#if>
    <title>${msg("loginTitle",(realm.displayName!''))}</title>
    <link rel="icon" href="${url.resourcesPath}/img/logo.svg" />
    <#if properties.stylesCommon?has_content>
        <#list properties.stylesCommon?split(' ') as style>
            <link href="${url.resourcesCommonPath}/${style}" rel="stylesheet" />
        </#list>
    </#if>
    <#if properties.styles?has_content>
        <#list properties.styles?split(' ') as style>
            <link href="${url.resourcesPath}/${style}" rel="stylesheet" />
        </#list>
    </#if>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
</head>
<body class="flash-dtf-body">
    <div class="flash-dtf-bg-overlay"></div>
    <div class="flash-dtf-container">
        <div class="flash-dtf-card">
            <#-- Logo -->
            <div class="flash-dtf-logo">
                <img src="${url.resourcesPath}/img/logo.svg" alt="Flash DTF" />
            </div>

            <#-- Alerts / Messages -->
            <#if displayMessage && message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
                <div class="flash-dtf-alert flash-dtf-alert-${message.type}">
                    ${kcSanitize(message.summary)?no_esc}
                </div>
            </#if>

            <#-- Main content -->
            <div class="flash-dtf-form-wrapper">
                <#nested "form">
            </div>

            <#-- Info section (registration link, etc.) -->
            <#if displayInfo>
                <div class="flash-dtf-info">
                    <#nested "info">
                </div>
            </#if>
        </div>
    </div>
</body>
</html>
</#macro>
