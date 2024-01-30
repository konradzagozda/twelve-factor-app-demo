from uuid import UUID

from django.db.models import QuerySet
from django.http import HttpRequest
from ninja import Router

from config.schemas import Error
from todos.errors import TODO_NOT_FOUND
from todos.models import Todo
from todos.schemas import TodoAll, TodoCreate, TodoPatch

router = Router()


@router.post("/", response={201: TodoAll})
def create_todo(request: HttpRequest, data: TodoCreate) -> tuple[int, Todo]:
    return 201, Todo.objects.create(title=data.title, description=data.description)


@router.get("/", response={200: list[TodoAll]})
def list_todos(request: HttpRequest) -> tuple[int, QuerySet[Todo]]:
    return 200, Todo.objects.all()


@router.get("/{todo_id}/", response={200: TodoAll, 404: Error})
def get_todo(request: HttpRequest, todo_id: UUID) -> tuple[int, Todo | Error]:
    try:
        return 200, Todo.objects.get(id=todo_id)
    except Todo.DoesNotExist:
        return 404, Error(
            type=TODO_NOT_FOUND.type,
            title=TODO_NOT_FOUND.title,
            detail=TODO_NOT_FOUND.detail.format(str(todo_id)),
        )


@router.patch("/{todo_id}/", response={200: TodoAll, 404: Error})
def partial_update_todo(
    request: HttpRequest, todo_id: UUID, data: TodoPatch
) -> tuple[int, Todo | Error]:
    try:
        todo = Todo.objects.get(id=todo_id)
    except Todo.DoesNotExist:
        return 404, Error(
            type=TODO_NOT_FOUND.type,
            title=TODO_NOT_FOUND.title,
            detail=TODO_NOT_FOUND.detail.format(str(todo_id)),
        )

    if data.title is not None:
        todo.title = data.title
    if data.description is not None:
        todo.description = data.description
    if data.completed is not None:
        todo.completed = data.completed

    todo.save()
    return 200, todo


@router.delete("/{todo_id}/", response={204: None})
def delete_todo(request: HttpRequest, todo_id: UUID) -> tuple[int, None]:
    Todo.objects.filter(id=todo_id).delete()
    return 204, None
