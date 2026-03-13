
# SAP RAP – Unmanaged Mobile Inventory System

## Project Overview

The **Unmanaged Mobile Inventory System** is an SAP RAP-based application designed to manage mobile device inventory within an organization.
The project is developed using the **ABAP RESTful Application Programming Model (RAP)** with **OData V2 service exposure**, enabling seamless integration with SAP Fiori applications.

This system allows users to manage mobile inventory details such as device information, suppliers, and pricing details while supporting advanced RAP architecture components like **CDS Views, Behavior Definitions, Service Definitions, and Service Bindings**.

**Demo 1**
<img width="1862" height="916" alt="image" src="https://github.com/user-attachments/assets/15af6041-a2c2-48a6-b2a9-c515d6a2a785" />

**Demo 2**
<img width="1851" height="872" alt="image" src="https://github.com/user-attachments/assets/05c54b0b-c7b2-4b92-95e8-645a39566321" />

---

## Key Features

* 📱 Manage mobile device inventory
* 🏷 Maintain supplier information
* 💰 Discount handling using popup structure
* 🔎 CDS-based data modeling
* 🔗 OData V2 service exposure for SAP Fiori
* ⚙ RAP **Unmanaged Implementation**
* 📊 Structured metadata extension for UI annotations

---

## Technology Stack

* **SAP ABAP RESTful Application Programming Model (RAP)**
* **Core Data Services (CDS)**
* **OData V2**
* **SAP Fiori Elements**
* **ABAP Development Tools (ADT) in Eclipse**

---

## Project Structure

### Package

```
ZUMI_083 – Unmanaged Mobile Inventory
```

### Authorizations

Handles authorization defaults for transport and binding.

```
Authorization Defaults (TADIR)
ZUI_MOBINV_BIND_083_0001
ZUI_MOBINV_BIND_083
```

### Business Services

#### Service Definition

```
ZUI_MOBINV_U_083
```

Defines the OData service for the mobile inventory system.

#### Service Binding

```
ZUI_MOBINV_BIND_083
```

OData V2 UI service used for SAP Fiori Elements.

---

## Core Data Services (CDS)

### Root View

```
ZI_MOBINV_U_083
```

Represents the **main mobile inventory data model**.

### Projection View

```
ZC_MOBINV_U_083
```

Projection layer used for **UI consumption**.

### Supplier View

```
ZI_SUPPLIER_083
```

Used to maintain **supplier contact information**.

### Additional Data Structures

```
ZAB_DISCOUNT_083
```

Used for **discount popup functionality**.

---

## Behavior Definition

```
ZC_MOBINV_U_083
ZI_MOBINV_U_083
```

Defines the **unmanaged behavior implementation** controlling:

* Create
* Update
* Delete
* Business logic operations

---

## Metadata Extensions

```
ZC_MOBINV_U_083
```

Used to define **UI annotations** for SAP Fiori Elements applications.

---

## Functional Workflow

1. User accesses the **Fiori application**.
2. Fiori calls the **OData V2 service**.
3. The service uses **CDS Projection View**.
4. Projection view retrieves data from **CDS Root View**.
5. Behavior implementation handles business logic.
6. Data is stored and retrieved from the underlying database tables.

---

## System Architecture

```
SAP Fiori UI
     │
     ▼
OData V2 Service Binding
     │
     ▼
Service Definition
     │
     ▼
CDS Projection View (ZC_MOBINV_U_083)
     │
     ▼
CDS Root View (ZI_MOBINV_U_083)
     │
     ▼
Database Tables
```

---
**Output**

**Preview **
https://drive.google.com/file/d/1auZh6YMUUOXwpy7YYIBVd9AHsCcL4rRs/view?usp=sharing

## Learning Outcomes

Through this project, the following SAP RAP concepts were implemented:

* RAP Unmanaged Scenario
* CDS Data Modeling
* Behavior Definitions
* Service Definition and Binding
* Metadata Extensions
* OData Exposure
* SAP Fiori Integration

---

## Author

**Kowsick K**

SAP ABAP Developer (Learner)

Chennai Institute of Technology

---

## Future Enhancements

* Add **Draft Handling**
* Implement **Validation and Determinations**
* Integrate **Analytics Dashboard**
* Extend with **Mobile Application UI**
