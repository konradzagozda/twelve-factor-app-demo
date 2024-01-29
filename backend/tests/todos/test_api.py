import pytest

from todos.models import Todo


@pytest.mark.django_db
def test_list_todos(api_client, sample_todo):
    response = api_client.get("/api/todos/")
    assert response.status_code == 200
    assert len(response.json()) == 1


@pytest.mark.django_db
def test_create_todo(api_client):
    response = api_client.post(
        "/api/todos/", {"title": "New Todo", "description": "New Description"}, "application/json"
    )
    assert response.status_code == 201
    assert Todo.objects.count() == 1


@pytest.mark.django_db
def test_get_todo(api_client, sample_todo):
    response = api_client.get(f"/api/todos/{sample_todo.id}/")
    assert response.status_code == 200
    assert response.json()["id"] == sample_todo.id


@pytest.mark.django_db
def test_partial_update_todo(api_client, sample_todo):
    response = api_client.patch(
        f"/api/todos/{sample_todo.id}/", {"title": "Updated Title"}, "application/json"
    )
    assert response.status_code == 200
    sample_todo.refresh_from_db()
    assert sample_todo.title == "Updated Title"


@pytest.mark.django_db
def test_delete_todo(api_client, sample_todo):
    response = api_client.delete(f"/api/todos/{sample_todo.id}/")
    assert response.status_code == 204
    assert Todo.objects.count() == 0
