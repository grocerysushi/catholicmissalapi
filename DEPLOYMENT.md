# Deployment Guide - Catholic Missal API

This guide covers various deployment options for the Catholic Missal API.

## 🐳 Docker Deployment (Recommended)

### Quick Start with Docker

```bash
# Build the image
docker build -t catholic-missal-api .

# Run the container
docker run -d \
  --name catholic-missal-api \
  -p 8000:8000 \
  --env-file .env \
  catholic-missal-api

# View logs
docker logs catholic-missal-api
```

### Docker Compose (Production)

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## ☁️ Cloud Deployment Options

### 1. Heroku

Create `Procfile`:
```
web: uvicorn app.main:app --host=0.0.0.0 --port=${PORT:-8000}
```

Deploy:
```bash
# Install Heroku CLI
heroku create your-catholic-missal-api

# Set environment variables
heroku config:set LOG_LEVEL=INFO

# Deploy
git push heroku main
```

### 2. Google Cloud Run

```bash
# Build and push to Container Registry
gcloud builds submit --tag gcr.io/PROJECT-ID/catholic-missal-api

# Deploy to Cloud Run
gcloud run deploy --image gcr.io/PROJECT-ID/catholic-missal-api --platform managed
```

### 3. AWS ECS/Fargate

1. Push image to ECR
2. Create ECS task definition
3. Deploy to Fargate service

### 4. DigitalOcean App Platform

1. Connect GitHub repository
2. Configure build settings:
   - Build command: `pip install -r requirements.txt`
   - Run command: `uvicorn app.main:app --host=0.0.0.0 --port=8000`

## 🖥️ VPS Deployment

### Ubuntu/Debian Server

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Python and dependencies
sudo apt install python3 python3-pip python3-venv nginx -y

# Clone repository
git clone <your-repo-url>
cd catholic-missal-api

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Install process manager
pip install gunicorn

# Create systemd service
sudo nano /etc/systemd/system/catholic-missal-api.service
```

Systemd service file:
```ini
[Unit]
Description=Catholic Missal API
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/path/to/catholic-missal-api
Environment=PATH=/path/to/catholic-missal-api/venv/bin
ExecStart=/path/to/catholic-missal-api/venv/bin/gunicorn -w 4 -k uvicorn.workers.UvicornWorker app.main:app --bind 0.0.0.0:8000
Restart=always

[Install]
WantedBy=multi-user.target
```

Start service:
```bash
sudo systemctl enable catholic-missal-api
sudo systemctl start catholic-missal-api
sudo systemctl status catholic-missal-api
```

### Nginx Configuration

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable SSL with Let's Encrypt:
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

## 📊 Monitoring and Logging

### Application Monitoring

1. **Health Check Endpoint**: `/api/v1/info`
2. **Logs**: Configure structured logging
3. **Metrics**: Use Prometheus/Grafana
4. **Alerts**: Set up uptime monitoring

### Log Configuration

Set environment variables:
```env
LOG_LEVEL=INFO
LOG_FORMAT=json
```

### Performance Monitoring

- Monitor response times
- Track API usage patterns
- Monitor external data source availability
- Set up alerts for failures

## 🔒 Security Considerations

### HTTPS/SSL
- Always use HTTPS in production
- Implement proper certificate management
- Use security headers

### API Security
- Implement rate limiting
- Use CORS appropriately
- Monitor for abuse
- Consider API keys for high-volume users

### Data Protection
- Respect data source rate limits
- Implement proper caching
- Monitor bandwidth usage
- Ensure copyright compliance

## 🔧 Environment Variables

Production environment variables:

```env
# API Configuration
API_V1_STR=/api/v1
PROJECT_NAME=Catholic Missal API
VERSION=1.0.0

# Data Sources
USCCB_BASE_URL=https://bible.usccb.org
VATICAN_BASE_URL=https://www.vatican.va

# Performance
RATE_LIMIT_REQUESTS=60
CACHE_EXPIRE_TIME=3600
READINGS_CACHE_TIME=86400

# Database (if using)
DATABASE_URL=postgresql://user:pass@localhost/catholic_missal

# Security
CORS_ORIGINS=https://yourdomain.com,https://www.yourdomain.com

# Monitoring
LOG_LEVEL=INFO
SENTRY_DSN=your-sentry-dsn  # Optional
```

## 🚀 Performance Optimization

### Caching Strategy
- Implement Redis for distributed caching
- Cache liturgical calculations
- Cache external API responses
- Use CDN for static content

### Database Optimization
- Use connection pooling
- Implement read replicas
- Optimize queries
- Regular maintenance

### Application Optimization
- Use async/await properly
- Implement connection pooling
- Optimize data structures
- Profile and monitor performance

## 📈 Scaling Considerations

### Horizontal Scaling
- Use load balancers
- Implement session-less design
- Use external caching
- Database clustering

### Vertical Scaling
- Monitor resource usage
- Optimize memory usage
- CPU optimization
- I/O optimization

## 🔄 Backup and Recovery

### Data Backup
- Regular database backups
- Configuration backups
- Code repository backups
- External data source monitoring

### Disaster Recovery
- Multi-region deployment
- Automated failover
- Data replication
- Recovery procedures

## 📞 Support and Maintenance

### Regular Maintenance
- Update dependencies
- Monitor security advisories
- Review logs regularly
- Test backup procedures

### Liturgical Updates
- Monitor for liturgical changes
- Update calendar calculations
- Verify data source accuracy
- Test seasonal transitions

---

## 🙏 Final Notes

Remember that this API serves the Catholic community. Ensure:

- High availability during important liturgical seasons
- Accurate liturgical information
- Respectful use of Church resources
- Proper attribution and copyright compliance

*Ad Majorem Dei Gloriam* - For the Greater Glory of God