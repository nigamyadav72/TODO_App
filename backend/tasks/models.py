from django.db import models
from django.contrib.auth.models import User

class TaskGroup(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='task_groups')
    name = models.CharField(max_length=100)
    type = models.CharField(max_length=50, choices=[('Work', 'Work'), ('Personal', 'Personal'), ('Daily', 'Daily')])
    
    def __str__(self):
        return f"{self.name} ({self.user.username})"

class Task(models.Model):
    STATUS_CHOICES = [
        ('To-do', 'To-do'),
        ('In Progress', 'In Progress'),
        ('Done', 'Done'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='tasks')
    group = models.ForeignKey(TaskGroup, on_delete=models.CASCADE, related_name='tasks', null=True, blank=True)
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    start_time = models.DateTimeField()
    end_time = models.DateTimeField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='To-do')
    category = models.CharField(max_length=50, default='Work')
    
    def __str__(self):
        return self.title
