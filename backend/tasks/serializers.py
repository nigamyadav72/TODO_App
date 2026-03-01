from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Task, TaskGroup

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email')

class TaskGroupSerializer(serializers.ModelSerializer):
    total_tasks = serializers.IntegerField(read_only=True)
    completed_tasks = serializers.IntegerField(read_only=True)

    class Meta:
        model = TaskGroup
        fields = '__all__'
        read_only_fields = ('user',)

class TaskSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = '__all__'
        read_only_fields = ('user',)
