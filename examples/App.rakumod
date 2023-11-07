use TodoList;
use HTML::Component;
use HTML::Component::Boilerplate;
unit class App does HTML::Component;

method RENDER($?) {
  boilerplate
    :title("My TODO list"),
    *.add-child: TodoList.new
}
