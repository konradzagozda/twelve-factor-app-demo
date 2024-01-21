from django.db.models import QuerySet
from django.http import HttpRequest
from ninja import Router

from config.schemas import ErrorSchema
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


@router.get("/{todo_id}", response={200: TodoAll, 404: ErrorSchema})
def get_todo(request: HttpRequest, todo_id: int) -> tuple[int, Todo | ErrorSchema]:
    try:
        return 200, Todo.objects.get(id=todo_id)
    except Todo.DoesNotExist:
        return 404, ErrorSchema(
            type=TODO_NOT_FOUND.type, title=TODO_NOT_FOUND.title, detail=TODO_NOT_FOUND.detail.format(todo_id)
        )


@router.patch("/{todo_id}", response={200: TodoAll})
def partial_update_todo(request: HttpRequest, todo_id: int, data: TodoPatch) -> Todo:
    todo = Todo.objects.get(id=todo_id)

    if data.title is not None:
        todo.title = data.title
    if data.description is not None:
        todo.description = data.description
    if data.completed is not None:
        todo.completed = data.completed

    todo.save()
    return todo


@router.delete("/{todo_id}", response={204: None})
def delete_todo(request: HttpRequest, todo_id: int) -> tuple[int, None]:
    Todo.objects.filter(id=todo_id).delete()
    return 204, None
