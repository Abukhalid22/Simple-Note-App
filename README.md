# Project Documentation


### **Introduction**

I worked on developing a note taking app, leveraging key DevOps practices. This involved using Django and React for the app's development, Docker for containerization, GitHub Actions for streamlining CI/CD processes, and Kubernetes for orchestration.

### **Project Overview**

The Notes App allows users to add, edit, and delete their notes, as well as view a list of notes. It's built with Django, utilizing the Django REST Framework for the backend, and React for the frontend. To ensure scalability and consistent deployment environments, the backend API is containerized with Docker. Similarly, the frontend is also containerized, allowing seamless interactions with the backend via API calls for a dynamic user experience.

The deployment and orchestration of the application are managed with Kubernetes, complemented by GitHub Actions for streamlined continuous integration and deployment processes. Additionally, integration with Argo CD enhances the deployment workflow, enabling automatic syncing of the application with the desired state in the Git repository, further automating and optimizing the continuous delivery pipeline.

### Dockerization

Dockerfiles are created for both the Django backend and React frontend, specifying the environment, dependencies, and commands needed to run each part of the application. **.dockerignore** files are used to exclude unnecessary files from the Docker build context, optimizing the build process.

### **Backend Dockerfile**

The Dockerfile for Django sets up the Python environment, installs dependencies from the **requirements.txt** file, and specifies the command to run the Django application.

### **Frontend Dockerfile**

The React application's Dockerfile configures a Node.js environment, installs npm dependencies, and builds the React application for production.

### GitHub Actions for CI/CD

The **ci-cd-pipeline.yaml** file defines the GitHub Actions workflow, automating the testing, building, and deployment processes. This CI/CD pipeline is triggered on every push to the repository, ensuring that changes are automatically built and tested. Docker images are built for both the frontend and backend and then pushed to Docker Hub. The workflow uses secrets for Docker Hub authentication, ensuring security.

### Kubernetes Orchestration

Kubernetes resources are defined in the **k8s** directory, including deployments, services, and ingress configurations. These definitions ensure that the Docker containers are deployed to a Kubernetes cluster, with the necessary networking and scaling configurations applied. Minikube is used for local Kubernetes development, offering a straightforward way to test Kubernetes deployments on a personal machine.

Minikube's **tunnel** command is utilized to expose the application, allowing local access to the React frontend, which communicates with the Django backend through internal Kubernetes networking.

### **Continuous Deployment with Argo CD**

Argo CD is integrated into the Kubernetes setup to enable continuous deployment. It monitors the **k8s** directory for changes and automatically applies updates to the Kubernetes cluster when new Docker image tags are pushed to Docker Hub. This ensures that the application is always up to date with the latest changes in the codebase.

### **Future Improvements**

This document has detailed the creation and deployment of a Notes Application using Django, React, Docker, GitHub Actions, and Kubernetes, embodying the principles of CI/CD and DevOps. Future improvements could include transitioning to cloud services for enhanced scalability and resilience, implementing more comprehensive testing within the CI pipeline, and exploring more advanced Kubernetes features for auto-scaling and self-healing.

### **Explaining Django Source Code**

This project demonstrates how to create a RESTful API using Django and the Django REST Framework, which allows for creating, retrieving, updating, and deleting notes.

### Models.py

```python
from django.db import models

# Define the Note model
class Note(models.Model):
    body = models.TextField(null=True, blank=True)  # The content of the note
    updated = models.DateTimeField(auto_now=True)  # Automatically set to now when the note is updated
    created = models.DateTimeField(auto_now_add=True)  # Automatically set to now when the note is created

    def __str__(self):
        return self.body[0:50]  # String representation of the Note object

```

In **models.py**, we define a **Note** model with three fields: **body**, **updated**, and **created**. The **body** field stores the text of the note, while **updated** and **created** fields automatically record the timestamps for when the note is updated and created, respectively.

### Serializers.py

```python
from rest_framework.serializers import ModelSerializer
from .models import Note

# Serializer for the Note model
class NoteSerializer(ModelSerializer):
    class Meta:
        model = Note  # Specify the model to serialize
        fields = '__all__'  # Include all fields of the model

```

The **NoteSerializer** class converts instances of the **Note** model to and from JSON format. By specifying **__all__** in the **fields** attribute, we include all fields of the **Note** model in the serialization process.

### urls.py (API Folder)

```python
from django.urls import path
from . import views

urlpatterns = [
    path('', views.getRoutes, name="Routes"),
    path('notes/', views.getNotes, name="notes"),
    path('notes/create/', views.createNote, name="create-note"),
    path('notes/<str:pk>/update/', views.updateNote, name="update-note"),
    path('notes/<str:pk>/delete/', views.deleteNote, name="delete-note"),
    path('notes/<str:pk>/', views.getNote, name="note"),
]

```

This **urls.py** file defines the URL patterns for our API endpoints. Each path is associated with a view function in **views.py** that handles the corresponding HTTP request.

### views.py

```python
from django.shortcuts import render
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Note
from .serializers import NoteSerializer

@api_view(["GET"])
def getRoutes(request):
    routes = [
        # Define available routes and their descriptions
    ]
    return Response(routes)

@api_view(["GET"])
def getNotes(request):
    notes = Note.objects.all().order_by("-updated")
    serializer = NoteSerializer(notes, many=True)
    return Response(serializer.data)

@api_view(["GET"])
def getNote(request, pk):
    note = Note.objects.get(id=pk)
    serializer = NoteSerializer(note, many=False)
    return Response(serializer.data)

@api_view(["POST"])
def createNote(request):
    data = request.data
    note = Note.objects.create(body=data['body'])
    serializer = NoteSerializer(note, many=False)
    return Response(serializer.data)

@api_view(["PUT"])
def updateNote(request, pk):
    data = request.data
    note = Note.objects.get(id=pk)
    serializer = NoteSerializer(instance=note, data=data)
    if serializer.is_valid():
        serializer.save()
    return Response(serializer.data)

@api_view(["DELETE"])
def deleteNote(request, pk):
    note = Note.objects.get(id=pk)
    note.delete()
    return Response("Note was deleted!")

```

**views.py** contains the logic for handling requests to each API endpoint. We use the **@api_view** decorator to specify the allowed HTTP methods. The view functions interact with the **Note** model and use the **NoteSerializer** to serialize/deserialize data.

### Settings.py (mynotes Folder)

**Key Settings**:

- **MIDDLEWARE**: Includes **corsheaders.middleware.CorsMiddleware** to allow cross-origin requests.
- **CORS_ALLOW_ALL_ORIGINS**: Allows all origins for CORS.

### urls.py (mynotes Folder)

This **urls.py** file routes the base URL to the Django admin interface, includes the API URL patterns from the **api** app, and serves the **index.html** for the frontend.

```python
from django.contrib import admin
from django.urls import include, path
from django.views.generic import TemplateView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')),
    path('', TemplateView.as_view(template_name='index.html')),
]

```

It integrates the API with the Django project and connects the frontend to the Django backend.

### **React Frontend Documentation**

In this section, I'll break down the React source code for the frontend of our note-taking application. This includes a detailed explanation of the components, pages, and the configuration for Nginx, illustrating how each part contributes to the functionality of the application.

### Components

**AddButton.js**

```jsx
port React from 'react'
import {Link} from 'react-router-dom'
import {ReactComponent as AddIcon} from '../assets/add.svg'

const AddButton = () => {
  return (
    <Link to="/note/new" className="floating-button">
        <AddIcon />
    </Link>
  )
}

export default AddButton

```

- **AddButton.js** creates a floating action button (FAB) that links to the **/note/new** route for adding new notes.
- Utilizing React Router's **Link** component ensures seamless navigation within the SPA (Single Page Application). The **AddIcon**.

**Header.js**

```jsx
import React from 'react'

const Header = () => {
  return (
    <div className="app-header">
        <h1>My Notes (New Header 09:00)</h1>
    </div>
  )
}

export default Header

```

- Displays the application's main header.

**ListItem.js**

```jsx
import React from "react";
import { Link } from "react-router-dom";

let getTime = (note) => {
  return new Date(note.updated).toLocaleDateString();
};

let getTitle = (note) => {
  let title = note.body.split('\n')[0];
  if (title.length > 45) {
    return title.slice(0, 45);
  }
  return title;
};

let getContent = (note) => {
  let title = getTitle(note);
  let content = note.body.replaceAll('\n', ' ');
  content = content.replaceAll(title, '');

  if (content.length > 45) {
    return content.slice(0, 45) + '...';
  } else {
    return content;
  }
};

const ListItem = ({ note }) => {
  return (
    <Link to={`/note/${note.id}`}>
      <div className="notes-list-item">
        <h3>{getTitle(note)}</h3>
        <p><span>{getTime(note)}</span>{getContent(note)}</p>
      </div>
    </Link>
  );
};

export default ListItem;

```

- **ListItem.js** renders individual notes in the list, showing a title and content snippet.
- Functions **getTime**, **getTitle**, and **getContent** extract and format note details for concise display. **Link** enables navigation to a detailed view of each note.

### Pages

**NotePage.js**

```jsx
import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { ReactComponent as ArrowLeft } from "../assets/arrow-left.svg";

const NotePage = () => {
  const { id } = useParams();
  const [note, setNote] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    const getNote = async () => {
      if (id === 'new') return;
      try {
        let response = await fetch(`/api/notes/${id}`);
        let data = await response.json();
        setNote(data);
      } catch (error) {
        console.error("Error fetching note:", error);
      }
    };

    getNote();
  }, [id]);

  // Handlers for update, create, delete, and navigation actions
...

  return (
    // JSX for note display and interaction
...
  );
};

export default NotePage;

```

- Manages viewing, editing, and creating notes.
- Hooks (**useState**, **useEffect**) manage state and side effects. **useParams** and **useNavigate** from React Router enable parameter retrieval and programmable navigation, facilitating both note creation and editing within a unified component.

**NoteListPage.js**

```jsx
import React, { useState, useEffect } from 'react';
import ListItem from '../components/ListItem';
import AddButton from '../components/AddButton';

const NotesListPage = () => {
  let [notes, setNotes] = useState([]);

  useEffect(() => {
    const getNotes = async () => {
      let response = await fetch(`/api/notes/`);
      let data = await response.json();
      setNotes(data);
    };

    getNotes();
  }, []);

  return (
    <div className="notes">
      <div className="notes-header">
        <h2 className="notes-title">Notes</h2>
        <p className="notes-count">{notes.length}</p>
      </div>
      <div className="notes-list">
        {notes.map((note, index) => (
          <ListItem key={index} note={note} />
        ))}
      </div>
      <AddButton />
    </div>
  );
};

export default NotesListPage;

```

- Displays a list of notes.
- It fetches and renders notes using **useEffect** for fetching data on component mount and **useState** for managing state. Mapping over **notes** to render **ListItem** components for each note.

### Nginx Configuration

To serve the React application, Nginx can be configured as a reverse proxy that serves static files and proxies API requests to the backend.

```
server {
    listen 80;
    server_name example.com;

    location / {
        root /var/www/html/my-notes-frontend/build;
        try_files $uri /index.html;
    }

    location /api/ {
        proxy_pass http://localhost:5000;
    }
}

```

- Directs traffic for the frontend to the static files and API requests to the backend server.
- This setup ensures that the React app's routing works correctly and that API requests are correctly forwarded to the backend, encapsulating both the static file serving and API proxying in a single Nginx configuration.

### **Docker and GitHub Actions Documentation**

This documentation provides an overview of the Docker configurations and GitHub Actions implemented for the note-taking application. 

### Docker Configuration

**Django Dockerfile Explanation**

```
FROM python:3.11-slim
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
WORKDIR /django
COPY requirements.txt /django/
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt
COPY . /django/
CMD python manage.py migrate --noinput && gunicorn mynotes.wsgi:application --bind 0.0.0.0:8000

```

- **Base Image**: python:3.11-slim is chosen for its lightweight nature, providing a minimal environment with Python 3.11 installed.
- **Environment Variables**:
    - **PYTHONDONTWRITEBYTECODE**: Prevents Python from writing **.pyc** files to disk, which is unnecessary in a Docker container.
    - **PYTHONUNBUFFERED**: Ensures real-time output in the Docker logs, facilitating easier debugging.
- **Working Directory**: Sets **/django** as the working directory inside the container, creating a clear, isolated environment for the application's files.
- **Dependency Installation**: Copies the **requirements.txt** file and installs Python dependencies. This step is separated to leverage Docker's cache, speeding up rebuilds when dependencies don't change.
- **Application Files**: Copies the entire application into the working directory after installing dependencies.
- **Default Command**: Executes Django migrations and starts the Gunicorn server, binding it to all network interfaces inside the container.

**React Dockerfile Explanation**

```
FROM node:20-alpine as build-stage
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:stable-alpine
COPY --from=build-stage /app/build /usr/share/nginx/html
COPY nginx/nginx-setup.conf /etc/nginx/conf.d/default.conf
CMD ["nginx", "-g", "daemon off;"]

```

- **Build Stage**: Utilizes **node:20-alpine** to install dependencies and build the React application. Alpine is chosen for its minimal footprint.
- **Serving Stage**: Switches to **nginx:stable-alpine** to serve the built application. This separation between build and serve stages reduces the final image size, as build-time dependencies are not included.
- **Nginx Configuration**: Custom Nginx configuration is copied to optimize serving the React application, ensuring proper routing for the SPA.

### GitHub Actions CI/CD Pipeline

**Workflow Overview**: (**ci-cd-pipeline.yml)**

- **Trigger**: Activated on pushes to the **master/main** branch.
- **Environment Variables**: Defines Docker image tags for both the Django backend and React frontend, incorporating the Git commit SHA for versioning.

**Steps Explained**:

1. **Checkout Repository**: Fetches the latest code from the repository to build the Docker images.
2. **Login to Docker Hub**: Uses the **docker/login-action** to authenticate, enabling subsequent steps to push images to Docker Hub.
3. **Fetch Latest Changes**: Ensures the repository is up-to-date, building the latest version of the application.
4. **Build and Push Docker Images**: Executes for both Django and React, utilizing **docker/build-push-action** to build images from the Dockerfiles and push them to Docker Hub using the tags defined in environment variables.
5. **Update Kubernetes Manifests**: Uses **sed** to replace image tags in Kubernetes deployment manifests with the new versions.  If changes are detected (via **git diff**), it updates the manifests to reflect the new image tags, commits, and pushes these changes. This automation allows the Kubernetes cluster to always deploy the latest images.

### **Kubernetes Configuration for Django Backend and React Frontend**

A documentation for a Kubernetes (k8s) and ArgoCD setup involves explaining each configuration file in the context of deploying and managing a Django backend and a React frontend. Below will show each piece of the configuration, describing its role, functionality, and how it integrates into the application ecosystem.

### Django Backend Deployment (**django-deployment.yaml**)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: django-backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: django-backend
  template:
    metadata:
      labels:
        app: django-backend
    spec:
      containers:
      - name: django-backend
        image: mctoosh94/mynotes:backend-c64e53ce8a889959c63c7ab655e4f4f784f1e2c5
        imagePullPolicy: Always
        ports:
        - containerPort: 8000
        env:
        - name: PYTHONUNBUFFERED
          value: "1"
        - name: PYTHONDONTWRITEBYTECODE
          value: "1"

```

**Explanation:**

- **Deployment Configuration**: Defines a deployment for the Django backend. A deployment ensures that a specified number of pod replicas are running at any time.
- **Replicas**: Specifies that only one instance of the pod should be running.
- **Selector and Labels**: Utilizes labels to manage the pods. The **app: django-backend** label is used to link the deployment to its pods.
- **Container Image**: Specifies the Docker image to use for the pod, alongside the policy to always pull the image to ensure the latest version is used.
- **Container Port**: Exposes port 8000 for the Django application, allowing it to receive traffic.
- **Environment Variables**: Sets environment variables to avoid Python from buffering outputs and to prevent writing **.pyc** files to disk.

### Django Service (**django-service.yaml**)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: django-backend-service
spec:
  type: ClusterIP
  ports:
  - port: 8000
    targetPort: 8000
  selector:
    app: django-backend

```

**Explanation:**

- **Service Configuration**: Defines a service to expose the Django backend pods. Services allow communication between different parts of an application.
- **Type**: **ClusterIP** makes the service only reachable within the cluster, which is ideal for internal APIs.
- **Ports**: Maps port 8000 on the service to port 8000 on the pods, facilitating access to the Django application.
- **Selector**: Connects the service to pods with the **app: django-backend** label.

### Ingress Configuration (**mynotes-ingress.yaml**)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mynotes-ingress
  annotations:
    nginx.ingress.kubernetes.io/cors-allow-origin: "*"
    nginx.ingress.kubernetes.io/cors-allow-methods: "GET, POST, PUT, DELETE, OPTIONS"
    nginx.ingress.kubernetes.io/cors-allow-headers: "Authorization, Origin, Content-Type, Accept"
    nginx.ingress.kubernetes.io/enable-cors: "true"
spec:
  rules:
  - http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: django-backend-service
            port:
              number: 8000
      - path: /
        pathType: Prefix
        backend:
          service:
            name: react-frontend-service
            port:
              number: 80

```

**Explanation:**

- **Ingress Configuration**: Defines rules for external access to the services within the cluster, using an Ingress controller.
- **Annotations**: Configures CORS to allow cross-origin requests, which is for the web application.
- **Routing Rules**: Directs traffic to the appropriate services based on the request path. **/api** requests are routed to the Django backend, while other paths are routed to the React frontend.

### React Frontend Deployment (**react-deployment.yaml**)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: react-frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: react-frontend
  template:
    metadata:
      labels:
        app: react-frontend
    spec:
      containers:
      - name: react-frontend
        image: mctoosh94/mynotes:frontend-c64e53ce8a889959c63c7ab655e4f4f784f1e2c5
        imagePullPolicy: Always
        ports:
        - containerPort: 80

```

**Explanation:**

- Similar to the Django deployment, but for the React frontend. Ensures that the React application is deployed and accessible.
- The container uses a specific Docker image for the frontend and exposes port 80 for web traffic.

### React Service (**react-service.yaml**)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: react-frontend-service
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30002
  selector:
    app: react-frontend

```

**Explanation:**

- **Service Configuration**: Exposes the React frontend pods externally.
- **Type**: **NodePort** exposes the service on each Node’s IP at a static port. This allows external access to the service, which is useful for development but can be replaced with a LoadBalancer or Ingress for production environments.
- **Ports Configuration**: Maps port 80 on the service to port 80 on the pods, and specifies the node port for external access.

## **The Workflow Overview**

When a code commit is pushed, this action triggers a series of orchestrated events designed to automate testing, building, and deployment processes, ensuring that new code changes are seamlessly integrated and deployed to the development/test environment with minimal human intervention. Here's a step-by-step breakdown of the workflow:

### **Step 1: Pushing a Commit**

A user pushes a commit to the GitHub repository. This could involve changes to the Django backend, the React frontend, or both. The commit serves as a signal to initiate the CI/CD pipeline.

### **Step 2: Triggering GitHub Actions**

The commit activates a predefined GitHub Actions workflow. This workflow contains jobs that may include linting code, running unit and integration tests, and building Docker images for both the Django and React parts of the application. 

### **Step 3: Building and Pushing Docker Images**

Upon passing the tests, Docker images for the Django backend and React frontend are built. These images are tagged with the specific commit SHA to ensure traceability. The images are then pushed to a Docker registry (DockerHub), making them available for deployment.

### **Step 4: Updating Kubernetes Configurations**

With the new Docker images ready, the Kubernetes deployment configurations (e.g., **django-deployment.yaml** and **react-deployment.yaml**) need to be updated to reference the newly built images. This step can be automated within the GitHub Actions workflow or managed through manual updates.

### **Step 5: Continuous Deployment with ArgoCD**

ArgoCD monitors the Kubernetes configurations stored in the repository. Once it detects changes (such as the updated Docker image tags), it automatically applies these changes to the Kubernetes cluster, effectively deploying the new version of the application. ArgoCD ensures that the state of the cluster matches the state defined in the repository, adhering to the principles of GitOps.

### **Step 6: Verification and Monitoring**

After deployment, automated scripts or manual checks can be performed to verify that the application is running as expected. This is where future enhancements, such as integrating Prometheus and Grafana for monitoring and alerting, can provide significant value. These tools can offer real-time insights into the application's performance and health, allowing proactive issue resolution and system optimization.

## **The Importance of This Integration**

This integration allows development teams with several key advantages:

- **Automated Testing and Deployment**: Automates the build, test, and deployment processes, reducing the potential for human error and speeding up the release cycle.
- **Consistency and Reliability**: Ensures that the application is deployed consistently across all environments, enhancing reliability and predictability.
- **Scalability**: Leverages Kubernetes for container orchestration, allowing the application to scale horizontally as demand fluctuates.
- **Traceability**: Every component of the application, from code to container, is versioned and traceable, simplifying rollback and debugging.
- **Efficiency**: Developers can focus more on feature development rather than operational concerns, improving productivity and innovation.

## **Future Improvements**

While the current setup provides a simple foundation, continuous improvement is key to maintaining an efficient and effective DevOps workflow. Potential enhancements include:

- **Monitoring and Alerting**: Integrating Prometheus for monitoring and Grafana for visualization can offer deeper insights into the application's performance and help identify issues before they impact users.
- **Service Mesh**: Adopting a service mesh like Istio could provide advanced traffic management, security, and observability features, further enhancing the application's resilience and performance.
- **Security Scanning**: Incorporating security scanning tools within the CI/CD pipeline can identify vulnerabilities early in the development process, reinforcing the application's security posture.
