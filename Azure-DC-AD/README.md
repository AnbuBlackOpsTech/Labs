# 🌐 Azure DC-AD Homelab

This repo documents my Azure homelab to create a **Domain Controler** in **Azure** and setting up **Active Directory**

---

## 🎯 Goals
- Hands-on practice in Azure Administrator skills
- Build a reusable knowledge base for myself and others

---

## 🛠️ Tools I’m Using
- **Azure Portal**
- **Azure CLI** (`az`)
- **Azure PowerShell**
- **Azure Bastion**

---

## 📖 Walkthrough

---

To start this homelab I would recomend signing up the free credit account in Azure. You will get $200 to use in 30 days to spin up the required resources and this will be more than enough for homelabing. 

---

First Click create a resource in the dashboard homepage.

<img width="3840" height="2160" alt="Screenshot 2025-08-19 220706" src="https://github.com/user-attachments/assets/94718b5c-dbb9-4894-91af-9704956e88a9" />

Next we want to create a **Virtual Machine** 

<img width="3840" height="2160" alt="Screenshot 2025-08-19 232041" src="https://github.com/user-attachments/assets/90a6b473-9f1e-42a2-8fd2-e675bbeea34f" />

We want to next configure the **Virtual Machine**. A resource group will also need to be created along with the VM details including the availability zones and what type of image we are using. Follow along the video to select the same options. We will need a Windows server image and the one I have selected is **Windows Server 2022 Datacenter: Azure Edition Hotpatch - Gen2**. Selecting an approritate SKU for the VM is also important and I have gone with **Standard E2s v3 (2 vcpus, 16 GiB memory)**. We will then need to create Admin credentials for the VM. For Inbound port rules we can select none as we will connect via **Azure Bastion**. We can then Review + Create as we will keep the default settings for everything else along with the standard OS disk (128GB). 

https://github.com/user-attachments/assets/7ba888e6-6127-4f5e-969d-e7408ba4ff95

It will now deploy the VM.

<img width="3840" height="2160" alt="Screenshot 2025-08-19 234901" src="https://github.com/user-attachments/assets/727c7315-8a09-4e02-80bc-18d3b687a19e" />

After the deployment is complete you will notice it has also deployed other resources needed for the VM to work in the Azure enviroment. These include the **Virtual Network Interface**, **VNET(Virtual Network)**, **NSG(Network Security Group)** and **Public IP**.

<img width="3840" height="2160" alt="Screenshot 2025-08-19 235137" src="https://github.com/user-attachments/assets/b0eaf6ee-2bb6-4f77-8585-536ca9c4915e" />

We want to change one network setting before remoting onto the VM. Go the VM from the resource group and click **Network Settings**. You then want to click on the **Network Interface**.

<img width="3840" height="2160" alt="Screenshot 2025-08-19 235831" src="https://github.com/user-attachments/assets/77b6f5b7-8987-4854-bba6-0e4ece41fdc5" />

Then click on the **ipconfig** and set the Private IP address to **Static** and save your changes. This is an important step as this VM is going to be our **Domain Controller**

<img width="3840" height="2160" alt="Screenshot 2025-08-19 235937" src="https://github.com/user-attachments/assets/b21e81e7-0f7e-4593-85d8-1ee1b17dd637" />

Now go back to your VM and click connect via **Bastion**.

<img width="3840" height="2160" alt="Screenshot 2025-08-20 000758" src="https://github.com/user-attachments/assets/f3f2dd33-6e87-4b2d-9453-3e94f2afe835" />

Enter your Admin credentials you created ealier and click connect. Note: You will need to enable pop-ups on your browser for this to work. 

<img width="3840" height="2160" alt="Screenshot 2025-08-20 001003" src="https://github.com/user-attachments/assets/0a5d78c4-a00b-4423-8c7e-a8a9dc44da70" />

You will now connect into the VM and login to the Admin Server account.

<img width="3840" height="2160" alt="Screenshot 2025-08-20 001029" src="https://github.com/user-attachments/assets/8deaaf80-d6f8-4a63-a8c4-84b3894d4660" />

You will get a prompt to allow connections to this PC to be discoverable, Click yes.

<img width="3840" height="2160" alt="Screenshot 2025-08-20 001111" src="https://github.com/user-attachments/assets/ae89f433-15b0-4cfe-a70f-f8137ec48540" />

Windows Server manager will automatically open and should look something like the below image.

<img width="3840" height="2160" alt="Screenshot 2025-08-20 001731" src="https://github.com/user-attachments/assets/7ea9195f-258e-4507-8939-90934edfde8b" />

We will now add roles and features so we can configure this VM as a **Domain Controller**. Follow along the video to select the following roles and features. We will be adding **Active Directory Domain Services (AD DS)**, **DHCP Server**, **DNS Server**, **Print and Document Services** and **Web Server(IIS)**.
These will be important for creating users and computers in the DC and managing print and web services down the line.

https://github.com/user-attachments/assets/572168e2-947e-4213-b7dd-22d6ea2e7aeb

After the setup is complete the **Server Manager** should look something like below.

<img width="3840" height="2160" alt="Screenshot 2025-08-20 002621" src="https://github.com/user-attachments/assets/3679f9f1-9140-4e6e-9bad-0495612477ba" />

We now want to promote the server to a **Domain Controller**. Click the flag icon on the top right and click "Promote this server to a Domain Controller."

<img width="3840" height="2160" alt="Screenshot 2025-08-20 004758" src="https://github.com/user-attachments/assets/2b88a78d-269e-438b-971b-9f2c9d3320a3" />

Follow along the video to configre the server promotion. You will need to create a **Root Dommain Name** and create a **DSRM Password**. Note: This usually has to be very strong but for this lab it is not of greate importance. We then continue with the wizard until we get to the prerequisite check. Once confirmed the checks are succesful we click install.

https://github.com/user-attachments/assets/1f905a8c-c750-4a95-9d88-b9186ec248cc

It will the prompt you to say the PC will now be restarted. This will restart the VM and kick you out of your **Bastion** session. You will then need to re-connect. 

<img width="3840" height="2160" alt="Screenshot 2025-08-20 005506" src="https://github.com/user-attachments/assets/098c8075-697f-4731-a811-7e3d0a374111" />

Once we get back into the VM we now search for **Active Directory Users and Computers (ADUC).

<img width="3840" height="2160" alt="Screenshot 2025-08-20 010809" src="https://github.com/user-attachments/assets/5aaa1c80-e70d-47df-aff5-93702b226e7a" />

We have now sucessfully promoted the DC ✅ and we can start creating users and computers in the next labs...

<img width="3840" height="2160" alt="Screenshot 2025-08-20 010847" src="https://github.com/user-attachments/assets/228e2310-4567-45d6-8bef-20fd4424f326" />



























































