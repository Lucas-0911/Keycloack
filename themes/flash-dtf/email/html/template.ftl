<#macro emailLayout>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            font-family: 'Inter', 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background-color: #f4f6f8;
            margin: 0;
            padding: 0;
            -webkit-font-smoothing: antialiased;
        }
        .container {
            max-width: 600px;
            margin: 40px auto;
            background-color: #ffffff;
            border-radius: 12px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.08);
            overflow: hidden;
            border: 1px solid #e2e8f0;
        }
        .header {
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            padding: 30px 20px;
            text-align: center;
        }
        .header h1 {
            margin: 0;
            font-size: 28px;
            font-weight: 800;
            letter-spacing: -0.5px;
        }
        .flash-text { color: #facc15; }
        .dtf-text { color: #ec4899; }
        .content {
            padding: 40px 30px;
            color: #334155;
            line-height: 1.6;
            font-size: 16px;
        }
        .content p {
            margin: 0 0 20px 0;
        }
        .footer {
            background-color: #f8fafc;
            padding: 24px;
            text-align: center;
            font-size: 13px;
            color: #64748b;
            border-top: 1px solid #e2e8f0;
        }
        .btn-container {
            text-align: center;
            margin: 30px 0;
        }
        .btn {
            display: inline-block;
            background-color: #0ea5e9;
            color: #ffffff !important;
            text-decoration: none;
            padding: 12px 32px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 16px;
            transition: background-color 0.2s;
        }
        .btn:hover {
            background-color: #0284c7;
        }
        .muted-text {
            color: #64748b;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <!-- You can also use an image logo here -->
            <h1><span class="flash-text">FLASH</span><span class="dtf-text">DTF</span></h1>
        </div>
        <div class="content">
            <#nested>
        </div>
        <div class="footer">
            <p>&copy; ${.now?string('yyyy')} Flash DTF. All rights reserved.</p>
            <p>This is an automated message, please do not reply.</p>
        </div>
    </div>
</body>
</html>
</#macro>
