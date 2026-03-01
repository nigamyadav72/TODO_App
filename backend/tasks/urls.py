from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import TaskViewSet, TaskGroupViewSet, login_view, register_view

router = DefaultRouter()
router.register(r'tasks', TaskViewSet, basename='task')
router.register(r'groups', TaskGroupViewSet, basename='group')

urlpatterns = [
    path('', include(router.urls)),
    path('auth/login/', login_view, name='login'),
    path('auth/register/', register_view, name='register'),
]
