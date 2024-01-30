import pytest

from todos.models import Todo


@pytest.fixture
def sample_todo() -> Todo:
    return Todo.objects.create(title="Sample Todo", description="Sample Description")
