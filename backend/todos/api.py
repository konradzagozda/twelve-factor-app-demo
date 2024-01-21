from django.db.models import QuerySet
from django.http import HttpRequest
from ninja import Router

from todos.models import Todo
from todos.schemas import TodoAll, TodoCreate, TodoPatch

router = Router()


@router.post("/", response=TodoAll)
def create_todo(request: HttpRequest, data: TodoCreate) -> Todo:
    return Todo.objects.create(title=data.title, description=data.description)


@router.get("/", response=list[TodoAll])
def list_todos(request: HttpRequest) -> QuerySet[Todo]:
    return Todo.objects.all()


@router.patch("/{todo_id}", response=TodoAll)
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
