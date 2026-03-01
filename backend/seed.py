import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from django.contrib.auth.models import User
from tasks.models import Task, TaskGroup
from django.utils import timezone
from datetime import timedelta

def seed_data():
    # Create user
    user, _ = User.objects.get_or_create(username='livia', email='livia@example.com')
    user.set_password('password123')
    user.save()
    
    # Create Task Groups
    work, _ = TaskGroup.objects.get_or_create(user=user, name='Office Project', type='Work')
    personal, _ = TaskGroup.objects.get_or_create(user=user, name='Personal Project', type='Personal')
    study, _ = TaskGroup.objects.get_or_create(user=user, name='Daily Study', type='Daily')
    
    # Create Tasks
    now = timezone.now()
    
    Task.objects.get_or_create(
        user=user, group=work, title='Market Research', 
        description='Grocery shopping app design',
        start_time=now, end_time=now + timedelta(hours=2),
        status='Done', category='Work'
    )
    
    Task.objects.get_or_create(
        user=user, group=work, title='Competitive Analysis', 
        description='Grocery shopping app design',
        start_time=now + timedelta(hours=3), end_time=now + timedelta(hours=5),
        status='In Progress', category='Work'
    )
    
    Task.objects.get_or_create(
        user=user, group=personal, title='Create Low-fidelity Wireframe', 
        description='Uber Eats redesign challenge',
        start_time=now + timedelta(hours=8), end_time=now + timedelta(hours=10),
        status='To-do', category='Personal'
    )

if __name__ == '__main__':
    seed_data()
    print("Database seeded successfully!")
