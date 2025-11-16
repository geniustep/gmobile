# تحليل شامل لمستودع Odoo Webhook Corp

## 📋 نظرة عامة

المستودع `odoo-webhook-corp` يحتوي على **مشروعين متكاملين** يعملان معاً لتوفير نظام webhook شامل لـ Odoo:

### المشروع الأول: FastAPI Webhook Server
**الموقع**: الجذر الرئيسي للمستودع
**التقنية**: FastAPI + Python 3.12+
**الإصدار**: v2.0.0

### المشروع الثاني: Odoo Module (custom-model-webhook)
**الموقع**: `/custom-model-webhook/`
**التقنية**: Odoo 18 Module
**الإصدار**: v1.0.0

---

## 🔷 المشروع الأول: FastAPI Webhook Server

### البنية العامة:

```
odoo-webhook-corp/
├── main.py                      # نقطة الدخول الرئيسية
├── config.py                    # إعدادات التطبيق
├── requirements.txt             # المتطلبات
├── Dockerfile                   # Docker containerization
├── docker-compose.yml           # Docker orchestration
│
├── webhook/                     # معالجة Webhooks
│   ├── __init__.py
│   ├── webhook.py              # استرجاع webhook events
│   └── update_webhook.py       # تتبع التحديثات
│
├── clients/                     # اتصال مع Odoo
│   └── odoo_client.py          # Odoo API client
│
├── core/                        # الأساسيات
│   └── auth.py                 # المصادقة (Session ID)
│
└── docs/                        # التوثيق
    ├── README.md
    ├── PROJECT_OVERVIEW.md
    ├── EXAMPLES.md
    └── UPGRADE_GUIDE_V2.md
```

---

### 1.1 التقنيات المستخدمة:

| التقنية | الغرض | الإصدار |
|---------|-------|---------|
| **FastAPI** | Web framework | Latest |
| **Uvicorn** | ASGI server | Latest |
| **HTTPX** | HTTP client | Latest |
| **SlowAPI** | Rate limiting | Latest |
| **python-dotenv** | Environment variables | Latest |

---

### 1.2 الـ Endpoints الرئيسية:

#### **API v1 (Legacy):**

```python
# 1. Health Check
GET /
Response: {
  "status": "running",
  "version": "2.0.0",
  "services": {...}
}

# 2. Webhook Events
GET /api/v1/webhook/events
Parameters:
  - session_id: string (required)
  - model: string (optional)
  - record_id: int (optional)
  - event: "create" | "write" | "unlink" (optional)
  - since: datetime ISO (optional)
  - limit: int (1-1000, default: 100)
  - offset: int (default: 0)
Response: [
  {
    "id": 123,
    "model": "sale.order",
    "record_id": 456,
    "event": "write",
    "occurred_at": "2024-01-15T10:30:00Z"
  }
]
Rate Limit: 30 requests/minute

# 3. Check Updates
GET /api/v1/check-updates
Parameters:
  - session_id: string (required)
  - since: datetime ISO (optional)
Response: {
  "has_update": true,
  "last_update_at": "2024-01-15T10:30:00Z",
  "summary": [
    {
      "model": "sale.order",
      "count": 5
    }
  ]
}
Rate Limit: 10 requests/minute

# 4. Cleanup Old Events
DELETE /api/v1/cleanup
Parameters:
  - session_id: string (required)
  - before: datetime ISO (required)
Response: {
  "deleted_count": 150,
  "message": "Successfully deleted 150 webhook events"
}
Rate Limit: 5 requests/minute
```

#### **API v2 (Smart Sync - New!):**

```python
# Multi-User Smart Sync
GET /api/v2/sync/pull
Parameters:
  - session_id: string (required)
  - device_id: string (required, unique per device)
  - app_type: "sales" | "delivery" | "manager" | "all"
  - models: array of strings (optional)
Response: {
  "has_update": true,
  "events": [
    {
      "model": "sale.order",
      "record_id": 123,
      "event": "write",
      "occurred_at": "2024-01-15T10:30:00Z",
      "data": {...}  // Full record data
    }
  ],
  "next_sync_token": "abc123..."
}

# Mark Events as Synced
POST /api/v2/sync/acknowledge
Parameters:
  - session_id: string
  - device_id: string
  - event_ids: array of integers
Response: {
  "acknowledged": 15,
  "message": "Successfully acknowledged 15 events"
}
```

---

### 1.3 المميزات الرئيسية:

#### ✅ **1. Multi-User Smart Sync (v2.0)**

**المشكلة السابقة (v1.0):**
- جميع المستخدمين يحصلون على نفس البيانات
- إذا قام أحد المستخدمين بـ cleanup، تُفقد البيانات للآخرين
- 2.88 مليون طلب يومياً

**الحل (v2.0):**
- كل مستخدم + جهاز لديه حالة sync خاصة
- تتبع فردي لما تم مزامنته
- Auto-archiving ذكي:
  - بعد 7 أيام: أرشفة إذا sync جميع المستخدمين
  - بعد 30 يوم: أرشفة إجبارية
  - بعد 90 يوم: حذف نهائي

**النتيجة:**
- 99.9% تخفيض في الطلبات (2,880 طلب يومياً)
- 99.9% تخفيض في حجم البيانات

```python
# Example: Sales App
GET /api/v2/sync/pull?app_type=sales&device_id=device123

# يحصل فقط على:
# - sale.order
# - res.partner
# - product.product
# ❌ لا يحصل على stock.picking أو hr.expense
```

#### ✅ **2. Rate Limiting**

```python
# مدمج في جميع الـ endpoints
@limiter.limit("30/minute")  # Webhook events
@limiter.limit("10/minute")  # Check updates
@limiter.limit("5/minute")   # Cleanup

# عند تجاوز الحد:
HTTP 429 Too Many Requests
{
  "error": "Rate limit exceeded. Please try again later."
}
```

#### ✅ **3. CORS Support**

```python
# المصادر المسموح بها:
allowed_origins = [
    "https://app.propanel.ma",
    "https://www.propanel.ma",
    "https://bridgecore.geniura.com",
    "http://localhost:3000",     # Development
    "http://localhost:5173",     # Vite
]

# HTTP Methods:
["GET", "POST", "DELETE", "OPTIONS"]

# Credentials: Supported
```

#### ✅ **4. Authentication**

```python
# Session ID Authentication
async def get_session_id(session_id: str = Header(...)):
    """
    يتحقق من صلاحية session_id مع Odoo
    """
    is_valid = await odoo_client.is_session_valid(session_id)
    if not is_valid:
        raise HTTPException(401, "Invalid session")
    return session_id

# Usage:
GET /api/v1/webhook/events
Headers:
  session_id: <your-odoo-session-id>
```

#### ✅ **5. Error Handling**

```python
# Odoo Error
if "error" in response:
    raise HTTPException(502, "Odoo server error")

# Server Error
except Exception as e:
    logger.error(f"Error: {e}")
    raise HTTPException(500, "Internal server error")
```

#### ✅ **6. Logging**

```python
# جميع العمليات تُسجل:
logger.info("📡 Webhook event received")
logger.warning("⚠️ Duplicate webhook detected")
logger.error("❌ Failed to create webhook")

# مع emoji indicators للوضوح
```

---

### 1.4 Odoo Client Implementation

```python
class OdooClient:
    """
    HTTP client للاتصال بـ Odoo
    """

    def __init__(
        self,
        base_url: str,
        session_id: str = None,
        timeout: int = 30,
        max_retries: int = 3
    ):
        self.base_url = base_url
        self.client = httpx.AsyncClient(
            timeout=timeout,
            cookies={"session_id": session_id}
        )

    # ════════════════════════════════════════════════════════════
    # Core Methods
    # ════════════════════════════════════════════════════════════

    async def call_kw(
        self,
        model: str,
        method: str,
        args: list,
        kwargs: dict = None
    ):
        """
        استدعاء method على model في Odoo
        """
        endpoint = f"{self.base_url}/web/dataset/call_kw"
        payload = {
            "jsonrpc": "2.0",
            "method": "call",
            "params": {
                "model": model,
                "method": method,
                "args": args,
                "kwargs": kwargs or {}
            }
        }

        response = await self.client.post(endpoint, json=payload)

        if "error" in response:
            raise OdooError(response["error"])

        return response["result"]

    # ════════════════════════════════════════════════════════════
    # High-level APIs
    # ════════════════════════════════════════════════════════════

    async def search_read(
        self,
        model: str,
        domain: list = None,
        fields: list = None,
        limit: int = None,
        offset: int = 0
    ):
        """
        البحث وقراءة السجلات
        """
        return await self.call_kw(
            model=model,
            method="search_read",
            args=[],
            kwargs={
                "domain": domain or [],
                "fields": fields,
                "limit": limit,
                "offset": offset
            }
        )

    async def create(self, model: str, vals: dict):
        """إنشاء سجل جديد"""
        return await self.call_kw(model, "create", [vals])

    async def write(self, model: str, ids: list, vals: dict):
        """تحديث سجلات"""
        return await self.call_kw(model, "write", [ids, vals])

    async def unlink(self, model: str, ids: list):
        """حذف سجلات"""
        return await self.call_kw(model, "unlink", [ids])

    # ════════════════════════════════════════════════════════════
    # Specialized Methods
    # ════════════════════════════════════════════════════════════

    async def get_updates_summary(self, since: datetime = None):
        """
        الحصول على ملخص التحديثات من update.webhook
        """
        domain = []
        if since:
            domain.append(["timestamp", ">=", since.isoformat()])

        events = await self.search_read(
            model="update.webhook",
            domain=domain,
            fields=["model", "record_id", "event", "timestamp"]
        )

        # تجميع حسب model
        summary = {}
        for event in events:
            model = event["model"]
            summary[model] = summary.get(model, 0) + 1

        return {
            "has_update": len(events) > 0,
            "last_update_at": max(e["timestamp"] for e in events) if events else None,
            "summary": [
                {"model": m, "count": c}
                for m, c in summary.items()
            ]
        }

    async def is_session_valid(self) -> bool:
        """
        التحقق من صلاحية session
        """
        try:
            endpoint = f"{self.base_url}/web/session/get_session_info"
            response = await self.client.post(endpoint, json={})
            return response["result"]["uid"] is not None
        except:
            return False
```

---

### 1.5 Deployment

#### **Option 1: Direct Python**

```bash
# Install dependencies
pip install -r requirements.txt

# Run server
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

#### **Option 2: Docker**

```dockerfile
# Dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
```

```yaml
# docker-compose.yml
version: '3.8'

services:
  webhook-server:
    build: .
    ports:
      - "8000:8000"
    environment:
      - ODOO_URL=https://app.propanel.ma
      - LOG_LEVEL=INFO
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped
```

```bash
# Deploy
docker-compose up -d

# View logs
docker-compose logs -f

# Scale
docker-compose up -d --scale webhook-server=3
```

---

## 🔶 المشروع الثاني: Odoo Module (custom-model-webhook)

### البنية العامة:

```
custom-model-webhook/
├── __manifest__.py              # Module metadata
├── __init__.py                  # Package initialization
│
├── models/                      # Data models
│   ├── __init__.py
│   ├── webhook.py              # WebhookMixin (abstract)
│   ├── update.py               # UpdateWebhook model
│   └── list_model.py           # Models with webhook
│
├── views/                       # UI views
│   ├── update_webhook_views.xml
│   └── webhook_menu.xml
│
└── security/                    # Access control
    └── ir.model.access.csv
```

---

### 2.1 Module Manifest

```python
{
    'name': 'Auto Webhook Flutter',
    'version': '1.0.0',
    'author': 'Odoo Zak, Odoo SA',
    'license': 'LGPL-3',
    'category': 'Tools',
    'sequence': 10,
    'summary': 'Auto Webhook for Odoo 18',
    'description': '''
        Automatic Webhook Registration for Odoo 18 Models.
        Keeps track of your records
    ''',

    # Dependencies
    'depends': [
        'base',
        'sale',
        'product',
        'account',
        'purchase',
        'stock',
        'hr_expense',
        'hr'
    ],

    # Data files
    'data': [
        'security/ir.model.access.csv',
        'views/update_webhook_views.xml',
        'views/webhook_menu.xml',
    ],

    # Installation
    'installable': True,
    'auto_install': False,
    'application': True,

    # Additional info
    'website': 'https://www.geniustep.com',
}
```

---

### 2.2 Core Models

#### **1. WebhookMixin (Abstract Model)**

```python
from odoo import models, api
import logging

_logger = logging.getLogger(__name__)

class WebhookMixin(models.AbstractModel):
    """
    Mixin لتتبع التغييرات على أي model

    Usage:
        class MyModel(models.Model):
            _name = 'my.model'
            _inherit = ['my.model', 'webhook.mixin']
    """
    _name = 'webhook.mixin'
    _description = 'Webhook Mixin for Change Tracking'

    def _log_webhook_event(self, event_type):
        """
        تسجيل webhook event

        Args:
            event_type: 'create' | 'write' | 'unlink'
        """
        events = []
        for record in self:
            events.append({
                'model': record._name,
                'record_id': record.id,
                'event': event_type,
                'timestamp': fields.Datetime.now()
            })

        # إنشاء webhook events
        self.env['update.webhook'].sudo().create(events)

        _logger.info(f"📡 Logged {len(events)} {event_type} events for {self._name}")

    @api.model_create_multi
    def create(self, vals_list):
        """Override create to log webhook"""
        records = super().create(vals_list)
        records._log_webhook_event('create')
        return records

    def write(self, vals):
        """Override write to log webhook"""
        result = super().write(vals)
        self._log_webhook_event('write')
        return result

    def unlink(self):
        """Override unlink to log webhook"""
        self._log_webhook_event('unlink')
        return super().unlink()
```

#### **2. UpdateWebhook Model**

```python
from odoo import models, fields, api
import logging

_logger = logging.getLogger(__name__)

class UpdateWebhook(models.Model):
    """
    جدول تخزين webhook events
    """
    _name = 'update.webhook'
    _description = 'Update Webhook'
    _order = 'timestamp desc'

    model = fields.Char('Model', required=True, index=True)
    record_id = fields.Integer('Record ID', required=True, index=True)
    event = fields.Selection([
        ('create', 'Create'),
        ('write', 'Write'),
        ('unlink', 'Delete')
    ], required=True)
    timestamp = fields.Datetime('Timestamp', default=fields.Datetime.now, index=True)

    # v2.0 fields for multi-user sync
    archived = fields.Boolean('Archived', default=False, index=True)
    archived_at = fields.Datetime('Archived At')

    _sql_constraints = [
        ('unique_webhook_event',
         'UNIQUE(model, record_id, event)',
         'Duplicate webhook event for the same record is not allowed!')
    ]

    @api.model_create_multi
    def create(self, vals_list):
        """
        إنشاء webhook events مع منع التكرار
        """
        created_events = []

        for vals in vals_list:
            model = vals.get('model')
            record_id = vals.get('record_id')
            event = vals.get('event')

            # البحث عن events موجودة
            existing = self.search([
                ('model', '=', model),
                ('record_id', '=', record_id),
                ('event', '=', event)
            ], limit=1)

            if existing:
                _logger.warning(
                    f"⚠️ Duplicate webhook: {model} #{record_id} {event}"
                )
                continue

            # منطق خاص: إذا كان event=create، احذف write
            if event == 'create':
                write_events = self.search([
                    ('model', '=', model),
                    ('record_id', '=', record_id),
                    ('event', '=', 'write')
                ])
                if write_events:
                    write_events.unlink()
                    _logger.info(
                        f"🗑️ Removed write events for {model} #{record_id}"
                    )

            # منطق خاص: إذا كان event=write وهناك create، تجاهل
            if event == 'write':
                create_exists = self.search([
                    ('model', '=', model),
                    ('record_id', '=', record_id),
                    ('event', '=', 'create')
                ], limit=1)
                if create_exists:
                    _logger.info(
                        f"✅ Skipped write (create exists): {model} #{record_id}"
                    )
                    continue

            created_events.append(vals)

        return super().create(created_events)
```

#### **3. WebhookErrors Model**

```python
class WebhookErrors(models.Model):
    """
    تتبع أخطاء webhook
    """
    _name = 'webhook.errors'
    _description = 'Webhook Errors'
    _order = 'timestamp desc'

    model = fields.Char('Model', required=True)
    record_id = fields.Integer('Record ID')
    error_message = fields.Text('Error Message', required=True)
    timestamp = fields.Datetime('Timestamp', default=fields.Datetime.now)
```

#### **4. WebhookCleanupCron Model**

```python
class WebhookCleanupCron(models.Model):
    """
    تنظيف webhook events للسجلات المحذوفة
    """
    _name = 'webhook.cleanup.cron'
    _description = 'Webhook Cleanup Cron'

    def cleanup_orphaned_webhooks(self):
        """
        حذف webhook events للسجلات التي تم حذفها
        """
        webhook_model = self.env['update.webhook']
        all_webhooks = webhook_model.search([])

        orphaned_count = 0

        for webhook in all_webhooks:
            model = webhook.model
            record_id = webhook.record_id

            # التحقق من وجود السجل
            try:
                record_exists = self.env[model].browse(record_id).exists()

                if not record_exists:
                    webhook.unlink()
                    orphaned_count += 1
                    _logger.info(
                        f"🗑️ Removed orphaned webhook: {model} #{record_id}"
                    )
            except Exception as e:
                _logger.error(f"❌ Error checking {model} #{record_id}: {e}")

        _logger.info(f"✅ Cleanup completed: {orphaned_count} orphaned webhooks removed")

        return orphaned_count
```

---

### 2.3 Models with Webhook Tracking

```python
# في list_model.py

from odoo import models

# Sales
class SaleOrder(models.Model):
    _name = 'sale.order'
    _inherit = ['sale.order', 'webhook.mixin']

class PurchaseOrder(models.Model):
    _name = 'purchase.order'
    _inherit = ['purchase.order', 'webhook.mixin']

# Products
class ProductTemplate(models.Model):
    _name = 'product.template'
    _inherit = ['product.template', 'webhook.mixin']

class ProductCategory(models.Model):
    _name = 'product.category'
    _inherit = ['product.category', 'webhook.mixin']

# Contacts
class ResPartner(models.Model):
    _name = 'res.partner'
    _inherit = ['res.partner', 'webhook.mixin']

# Accounting
class AccountMove(models.Model):
    _name = 'account.move'
    _inherit = ['account.move', 'webhook.mixin']

class AccountJournal(models.Model):
    _name = 'account.journal'
    _inherit = ['account.journal', 'webhook.mixin']

# HR
class HrEmployee(models.Model):
    _name = 'hr.employee'
    _inherit = ['hr.employee', 'webhook.mixin']

class HrExpense(models.Model):
    _name = 'hr.expense'
    _inherit = ['hr.expense', 'webhook.mixin']

# Inventory
class StockPicking(models.Model):
    _name = 'stock.picking'
    _inherit = ['stock.picking', 'webhook.mixin']
```

**الآن:**
- أي عملية create/write/unlink على هذه الـ models
- ستنشئ webhook event تلقائياً
- في جدول `update.webhook`

---

### 2.4 Views & Menu

#### **Tree View:**

```xml
<record id="view_update_webhook_list" model="ir.ui.view">
    <field name="name">update.webhook.list</field>
    <field name="model">update.webhook</field>
    <field name="arch" type="xml">
        <tree string="Webhook Updates"
              editable="top"
              create="false"
              delete="true">
            <field name="model"/>
            <field name="record_id"/>
            <field name="event"/>
            <field name="timestamp"/>
        </tree>
    </field>
</record>
```

#### **Form View:**

```xml
<record id="view_update_webhook_form" model="ir.ui.view">
    <field name="name">update.webhook.form</field>
    <field name="model">update.webhook</field>
    <field name="arch" type="xml">
        <form string="Webhook Update">
            <sheet>
                <group>
                    <field name="model"/>
                    <field name="record_id"/>
                    <field name="event"/>
                    <field name="timestamp"/>
                </group>
            </sheet>
        </form>
    </field>
</record>
```

#### **Menu:**

```xml
<menuitem id="menu_webhook_root"
          name="Webhooks"
          sequence="100"/>

<menuitem id="menu_update_webhook"
          name="Webhook Updates"
          parent="menu_webhook_root"
          action="action_update_webhook"
          sequence="10"/>
```

---

### 2.5 Security (Access Rights)

```csv
id,name,model_id:id,group_id:id,perm_read,perm_write,perm_create,perm_unlink
access_update_webhook,access.update.webhook,model_update_webhook,base.group_user,1,0,0,1
```

**التفسير:**
- ✅ **Read**: المستخدمون العاديون يمكنهم القراءة
- ❌ **Write**: لا يمكن التعديل (system-managed)
- ❌ **Create**: لا يمكن الإنشاء (automatic)
- ✅ **Unlink**: يمكن الحذف (للتنظيف اليدوي)

---

## 🔗 التكامل بين المشروعين

### كيف يعملان معاً:

```
┌─────────────────────────────────────────────────────────────┐
│                         Odoo 18                             │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  custom-model-webhook Module                          │ │
│  │                                                        │ │
│  │  1. User creates/updates/deletes record               │ │
│  │     ↓                                                  │ │
│  │  2. WebhookMixin intercepts the operation             │ │
│  │     ↓                                                  │ │
│  │  3. Creates event in update.webhook table             │ │
│  │     - model: "sale.order"                            │ │
│  │     - record_id: 123                                 │ │
│  │     - event: "write"                                 │ │
│  │     - timestamp: "2024-01-15T10:30:00Z"              │ │
│  └────────────────────────────────────────────────────────┘ │
│                           ↓                                  │
│                  update.webhook table                        │
│                  (stored in Odoo database)                   │
└──────────────────────────────┬───────────────────────────────┘
                               │
                               │ HTTP Request
                               │
                               ↓
┌─────────────────────────────────────────────────────────────┐
│              FastAPI Webhook Server                         │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Client App (Flutter/React/etc)                       │ │
│  │                                                        │ │
│  │  1. GET /api/v2/sync/pull                            │ │
│  │     Headers:                                          │ │
│  │       session_id: <odoo-session>                     │ │
│  │     Params:                                           │ │
│  │       device_id: "device123"                         │ │
│  │       app_type: "sales"                              │ │
│  │                                                        │ │
│  │  2. Server queries Odoo:                             │ │
│  │     - Uses odoo_client.search_read()                 │ │
│  │     - Model: "update.webhook"                        │ │
│  │     - Filters by user sync state                     │ │
│  │                                                        │ │
│  │  3. Response:                                         │ │
│  │     {                                                 │ │
│  │       "has_update": true,                            │ │
│  │       "events": [                                     │ │
│  │         {                                             │ │
│  │           "model": "sale.order",                     │ │
│  │           "record_id": 123,                          │ │
│  │           "event": "write",                          │ │
│  │           "data": {...}                              │ │
│  │         }                                             │ │
│  │       ]                                               │ │
│  │     }                                                 │ │
│  │                                                        │ │
│  │  4. Client processes events                          │ │
│  │  5. POST /api/v2/sync/acknowledge                    │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Use Cases & Examples

### **1. Sales App (Flutter)**

```dart
class SyncService {
  final String baseUrl = 'https://webhook.propanel.ma';
  final String sessionId;
  final String deviceId;

  Future<void> syncSalesData() async {
    // 1. Pull updates
    final response = await http.get(
      Uri.parse('$baseUrl/api/v2/sync/pull'),
      headers: {
        'session_id': sessionId,
      },
      queryParameters: {
        'device_id': deviceId,
        'app_type': 'sales',  // Only sales-related models
      },
    );

    final data = jsonDecode(response.body);

    if (data['has_update']) {
      // 2. Process events
      for (var event in data['events']) {
        switch (event['model']) {
          case 'sale.order':
            await _processSaleOrder(event);
            break;
          case 'res.partner':
            await _processPartner(event);
            break;
          case 'product.product':
            await _processProduct(event);
            break;
        }
      }

      // 3. Acknowledge
      await http.post(
        Uri.parse('$baseUrl/api/v2/sync/acknowledge'),
        headers: {
          'session_id': sessionId,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'device_id': deviceId,
          'event_ids': data['events'].map((e) => e['id']).toList(),
        }),
      );
    }
  }
}
```

### **2. Delivery App (React Native)**

```typescript
class DeliverySync {
  private baseUrl = 'https://webhook.propanel.ma';
  private sessionId: string;
  private deviceId: string;

  async syncDeliveries() {
    // 1. Pull updates for delivery
    const response = await fetch(
      `${this.baseUrl}/api/v2/sync/pull?` +
      `device_id=${this.deviceId}&` +
      `app_type=delivery`,
      {
        headers: {
          'session_id': this.sessionId,
        },
      }
    );

    const data = await response.json();

    if (data.has_update) {
      // 2. Filter stock.picking events
      const deliveries = data.events.filter(
        (e: any) => e.model === 'stock.picking'
      );

      // 3. Update local database
      for (const delivery of deliveries) {
        await this.updateLocalDelivery(delivery);

        // Send push notification
        if (delivery.event === 'create') {
          await this.sendNotification(
            'New Delivery',
            `New delivery #${delivery.record_id}`
          );
        }
      }

      // 4. Acknowledge
      await this.acknowledgeEvents(
        data.events.map((e: any) => e.id)
      );
    }
  }
}
```

### **3. Manager Dashboard (React)**

```javascript
class DashboardSync {
  constructor(sessionId, deviceId) {
    this.baseUrl = 'https://webhook.propanel.ma';
    this.sessionId = sessionId;
    this.deviceId = deviceId;
  }

  async checkUpdates() {
    // Check all models
    const response = await fetch(
      `${this.baseUrl}/api/v1/check-updates`,
      {
        headers: {
          'session_id': this.sessionId,
        },
      }
    );

    const data = await response.json();

    if (data.has_update) {
      // Display notification
      this.showNotification({
        title: 'New Updates Available',
        message: `${data.summary.length} models updated`,
        summary: data.summary,
      });
    }
  }

  showNotification({ title, message, summary }) {
    // Group by model
    const grouped = summary.reduce((acc, item) => {
      acc[item.model] = item.count;
      return acc;
    }, {});

    // Display
    console.log(title);
    console.log(message);
    Object.entries(grouped).forEach(([model, count]) => {
      console.log(`  ${model}: ${count} updates`);
    });
  }
}
```

### **4. Background Sync Service (Python)**

```python
import asyncio
import httpx
from datetime import datetime

class BackgroundSyncService:
    def __init__(self, base_url: str, session_id: str, device_id: str):
        self.base_url = base_url
        self.session_id = session_id
        self.device_id = device_id
        self.client = httpx.AsyncClient()

    async def run_continuous_sync(self):
        """
        Continuous sync every 30 seconds
        """
        while True:
            try:
                await self.sync_all_models()
                await asyncio.sleep(30)
            except Exception as e:
                print(f"❌ Sync error: {e}")
                await asyncio.sleep(60)  # Wait longer on error

    async def sync_all_models(self):
        # 1. Pull updates
        response = await self.client.get(
            f"{self.base_url}/api/v2/sync/pull",
            headers={"session_id": self.session_id},
            params={
                "device_id": self.device_id,
                "app_type": "all",
            },
        )

        data = response.json()

        if data["has_update"]:
            print(f"✅ Found {len(data['events'])} updates")

            # 2. Process by model
            for event in data["events"]:
                await self.process_event(event)

            # 3. Acknowledge
            await self.client.post(
                f"{self.base_url}/api/v2/sync/acknowledge",
                headers={"session_id": self.session_id},
                json={
                    "device_id": self.device_id,
                    "event_ids": [e["id"] for e in data["events"]],
                },
            )

    async def process_event(self, event):
        model = event["model"]
        record_id = event["record_id"]
        event_type = event["event"]

        if event_type == "create":
            await self.handle_create(model, record_id, event["data"])
        elif event_type == "write":
            await self.handle_update(model, record_id, event["data"])
        elif event_type == "unlink":
            await self.handle_delete(model, record_id)

# Usage
service = BackgroundSyncService(
    base_url="https://webhook.propanel.ma",
    session_id="<your-session-id>",
    device_id="background-sync-001"
)

asyncio.run(service.run_continuous_sync())
```

---

## 🎯 مقارنة v1.0 vs v2.0

| Feature | v1.0 | v2.0 |
|---------|------|------|
| **Sync Strategy** | Global (all users) | Per-user + per-device |
| **Data Filter** | Manual | Automatic by app_type |
| **Cleanup** | Manual (/api/v1/cleanup) | Automatic archiving |
| **Daily Requests** | 2.88M | 2,880 (-99.9%) |
| **Data Volume** | Full | Filtered (-99.9%) |
| **User Isolation** | ❌ No | ✅ Yes |
| **Data Loss Risk** | ⚠️ High | ✅ None |
| **Archive Timing** | N/A | 7/30/90 days |

---

## 💡 Best Practices

### 1. **Device ID**
```python
# ✅ Correct: Unique per physical device
device_id = f"{platform}_{device_uuid}"
# "android_abc123def456"
# "ios_xyz789uvw012"

# ❌ Wrong: Shared across devices
device_id = f"user_{user_id}"
```

### 2. **App Type Filtering**
```python
# Sales app
app_type = "sales"  # Only: sale.order, res.partner, product.*

# Delivery app
app_type = "delivery"  # Only: stock.picking, res.partner

# Admin dashboard
app_type = "all"  # Everything
```

### 3. **Error Handling**
```python
max_retries = 3
for attempt in range(max_retries):
    try:
        await sync()
        break
    except Exception as e:
        if attempt < max_retries - 1:
            await asyncio.sleep(2 ** attempt)  # Exponential backoff
        else:
            raise
```

### 4. **Offline Queue**
```python
# Queue events when offline
if not is_online():
    queue.append(event)
else:
    # Sync queue first
    for queued_event in queue:
        await sync_event(queued_event)
    queue.clear()

    # Then sync new events
    await sync_new_events()
```

---

## 🚀 الخلاصة

### المشروع الأول (FastAPI Server):
- ✅ **RESTful API** لجلب webhook events من Odoo
- ✅ **Multi-user sync** مع تتبع فردي
- ✅ **Auto-archiving** ذكي (7/30/90 days)
- ✅ **App-type filtering** للكفاءة
- ✅ **Rate limiting** للحماية
- ✅ **CORS support** للتطبيقات
- ✅ **Session authentication**
- ✅ **Docker ready**

### المشروع الثاني (Odoo Module):
- ✅ **WebhookMixin** قابل لإعادة الاستخدام
- ✅ **Automatic tracking** لجميع العمليات (create/write/unlink)
- ✅ **10 models مدمجة** (sales, products, partners, etc.)
- ✅ **Duplicate prevention** ذكي
- ✅ **Orphan cleanup** تلقائي
- ✅ **UI views** للمراقبة
- ✅ **Error tracking**

### النتيجة النهائية:
- 🚀 **99.9% تخفيض** في الطلبات والبيانات
- ⚡ **Real-time sync** فعال
- 💾 **Offline-first** مع queue
- 🔐 **آمن** مع session authentication
- 📊 **Scalable** مع Docker
- 🎯 **Production-ready**

---

**المشروعان يعملان معاً لتوفير حل webhook شامل وفعال لـ Odoo! 🎉**
