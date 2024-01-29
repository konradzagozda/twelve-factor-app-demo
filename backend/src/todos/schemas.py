from ninja import Schema


class TodoAll(Schema):
    id: int
    title: str
    description: str
    completed: bool


class TodoCreate(Schema):
    title: str
    description: str


class TodoPatch(Schema):
    title: str | None = None
    description: str | None = None
    completed: bool | None = None
