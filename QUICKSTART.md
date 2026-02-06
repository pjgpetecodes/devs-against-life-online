# Quick Start: Deploy to Existing Azure Web App

This guide helps you deploy Developers Against Humanity to an **existing** Azure Web App that you already have.

> **New to Azure?** If you don't have an Azure Web App yet, see [DEPLOYMENT.md](DEPLOYMENT.md) for instructions on creating new infrastructure.

## Prerequisites

Before you begin, ensure you have:

- ✅ An existing Azure Web App (App Service)
- ✅ Access to the Azure Portal or Azure CLI
- ✅ A GitHub account with this repository forked/cloned
- ✅ .NET 8.0 runtime configured on your Web App

## Quick Steps Overview

1. **Configure your Azure Web App** (enable WebSockets)
2. **Get your publish profile** from Azure
3. **Configure GitHub Actions** with the publish profile
4. **Deploy** by pushing to your repository

---

## Step 1: Configure Your Azure Web App

### Enable WebSockets (Required for SignalR)

SignalR requires WebSockets to be enabled on your Azure Web App.

#### Option A: Azure Portal

1. Open [Azure Portal](https://portal.azure.com)
2. Navigate to your App Service
3. Go to **Settings** > **Configuration**
4. Click the **General settings** tab
5. Set **Web sockets** to **On**
6. Click **Save**

#### Option B: Azure CLI

```bash
az webapp config set \
  --name YOUR-WEBAPP-NAME \
  --resource-group YOUR-RESOURCE-GROUP \
  --web-sockets-enabled true
```

### Verify .NET Runtime

Ensure your Web App is configured for .NET 8:

#### Azure Portal
1. Go to **Settings** > **Configuration** > **General settings**
2. Set **Stack** to **.NET**
3. Set **Major version** to **.NET 8 (LTS)**
4. Click **Save**

#### Azure CLI
```bash
az webapp config show \
  --name YOUR-WEBAPP-NAME \
  --resource-group YOUR-RESOURCE-GROUP \
  --query linuxFxVersion
```

---

## Step 2: Get Your Publish Profile

The publish profile contains credentials needed for deployment.

### Download from Azure Portal

1. Go to your App Service in Azure Portal
2. Click **Deployment Center** in the left menu
3. Click **Manage publish profile**
4. Click **Download publish profile**
5. Save the `.PublishSettings` file (you'll need its contents)

### Using Azure CLI

```bash
az webapp deployment list-publishing-profiles \
  --name YOUR-WEBAPP-NAME \
  --resource-group YOUR-RESOURCE-GROUP \
  --xml
```

Copy the entire XML output - this is your publish profile.

---

## Step 3: Configure GitHub Actions

### Add Publish Profile to GitHub Secrets

1. Go to your GitHub repository
2. Click **Settings** > **Secrets and variables** > **Actions**
3. Click **New repository secret**
4. Name: `AZURE_WEBAPP_PUBLISH_PROFILE`
5. Value: Paste the **entire contents** of your publish profile file
6. Click **Add secret**

### Update Workflow Configuration

Edit `.github/workflows/azure-deploy.yml`:

1. Find line 10: `AZURE_WEBAPP_NAME: 'dev-against-humanity'`
2. Replace `'dev-against-humanity'` with **your Azure Web App name**
3. Example: `AZURE_WEBAPP_NAME: 'my-existing-webapp'`

```yaml
env:
  AZURE_WEBAPP_NAME: 'your-webapp-name-here'  # ← Change this
  AZURE_WEBAPP_PACKAGE_PATH: './DevelopersAgainstHumanity'
  DOTNET_VERSION: '8.0.x'
```

4. Save and commit the change:

```bash
git add .github/workflows/azure-deploy.yml
git commit -m "Configure deployment for existing Azure Web App"
git push origin main
```

---

## Step 4: Deploy

### Option A: Automatic Deployment (Recommended)

Once configured, the app automatically deploys when you push to the `main` branch:

```bash
git push origin main
```

### Option B: Manual Workflow Trigger

1. Go to your GitHub repository
2. Click **Actions** tab
3. Select **Build and Deploy to Azure** workflow
4. Click **Run workflow** button
5. Select branch (usually `main`)
6. Click **Run workflow**

### Monitor Deployment

1. In GitHub, go to **Actions** tab
2. Click on the running workflow
3. Watch the build and deploy steps
4. Deployment usually takes 2-5 minutes

---

## Step 5: Verify Deployment

1. **Check deployment status**: Wait for GitHub Action to show ✅ success
2. **Visit your app**: Go to `https://YOUR-WEBAPP-NAME.azurewebsites.net`
3. **Test the game**:
   - You should see the game lobby
   - Enter a player name and room ID
   - Click "Join Room"
   - Open another browser tab/window and join the same room
   - Click "Start Game" (needs 3+ players)

### Troubleshooting

If you don't see the game:

1. **Check Application Logs**:
   ```bash
   az webapp log tail \
     --name YOUR-WEBAPP-NAME \
     --resource-group YOUR-RESOURCE-GROUP
   ```

2. **Verify WebSockets**: Make sure WebSockets are enabled (Step 1)

3. **Check Browser Console**: Press F12 and look for JavaScript errors

4. **Verify cards loaded**: Check logs for "Loaded X black cards" message

---

## Alternative Deployment Methods

### Deploy via Azure CLI

If you prefer not to use GitHub Actions:

```bash
# Navigate to project directory
cd DevelopersAgainstHumanity

# Build and publish
dotnet publish -c Release -o ./publish

# Create deployment package
cd publish
zip -r ../deploy.zip .
cd ..

# Deploy to Azure
az webapp deployment source config-zip \
  --name YOUR-WEBAPP-NAME \
  --resource-group YOUR-RESOURCE-GROUP \
  --src deploy.zip
```

### Deploy via VS Code

1. Install the [Azure App Service extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azureappservice)
2. Open the project in VS Code
3. Click the Azure icon in the sidebar
4. Right-click your Web App under **App Services**
5. Select **Deploy to Web App...**
6. Choose the `DevelopersAgainstHumanity` folder
7. Confirm deployment

### Deploy via Visual Studio

1. Open `DevelopersAgainstHumanity.sln`
2. Right-click the `DevelopersAgainstHumanity` project
3. Select **Publish...**
4. Choose **Azure** as target
5. Select **Azure App Service (Windows)** or **Azure App Service (Linux)**
6. Select your existing Web App
7. Click **Publish**

---

## Configuration & Customization

### Environment Variables

To add environment variables (e.g., API keys):

```bash
az webapp config appsettings set \
  --name YOUR-WEBAPP-NAME \
  --resource-group YOUR-RESOURCE-GROUP \
  --settings KEY1=value1 KEY2=value2
```

### Custom Cards

To customize the game cards:

1. Edit `black-cards.txt` (questions/prompts)
2. Edit `white-cards.txt` (answers)
3. Commit and push changes
4. Automatic deployment will update the cards

### Scale Your App

If you need more performance:

```bash
# Scale up (more CPU/memory)
az appservice plan update \
  --name YOUR-APP-SERVICE-PLAN \
  --resource-group YOUR-RESOURCE-GROUP \
  --sku S1

# Scale out (more instances)
az appservice plan update \
  --name YOUR-APP-SERVICE-PLAN \
  --resource-group YOUR-RESOURCE-GROUP \
  --number-of-workers 2
```

---

## Monitoring Your Deployment

### View Live Logs

```bash
az webapp log tail \
  --name YOUR-WEBAPP-NAME \
  --resource-group YOUR-RESOURCE-GROUP
```

### Enable Application Insights (Optional)

If your Web App doesn't have Application Insights:

1. Go to your App Service in Azure Portal
2. Click **Application Insights** in left menu
3. Click **Turn on Application Insights**
4. Create new or select existing Application Insights resource
5. Click **Apply**

---

## Security Checklist

Before going live:

- ✅ HTTPS is enabled (should be automatic)
- ✅ WebSockets are enabled
- ✅ Publish profile secret is secure in GitHub
- ✅ App Service authentication configured (if needed)
- ✅ CORS configured (if serving from different domain)

---

## Need Help?

- **Documentation**: See [README.md](README.md) for game overview
- **Full deployment guide**: See [DEPLOYMENT.md](DEPLOYMENT.md) for creating new infrastructure
- **Local testing**: See [LOCAL-TESTING.md](LOCAL-TESTING.md) for development setup
- **Security**: See [SECURITY.md](SECURITY.md) for security considerations
- **Issues**: Open an issue on GitHub

---

## Summary

**You're all set!** 🎉

Your deployment process:
1. ✅ Configured Azure Web App (WebSockets enabled)
2. ✅ Added publish profile to GitHub Secrets
3. ✅ Updated workflow with your Web App name
4. ✅ Pushed to GitHub → Automatic deployment

**Next time**: Just push code changes to trigger automatic deployment!

**To play**: Visit `https://YOUR-WEBAPP-NAME.azurewebsites.net`
