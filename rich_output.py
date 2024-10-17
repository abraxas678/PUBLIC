from rich.console import Console
from rich.panel import Panel
from rich.progress import Progress
from rich.live import Live
from rich.table import Table
from rich.layout import Layout
import sys
import time

console = Console()

def create_steps_table(steps, completed):
    table = Table(show_header=False, expand=True)
    for i, step in enumerate(steps, 1):
        status = "[green]✓[/green]" if i in completed else " "
        table.add_row(f"{status} {i}. {step}")
    return Panel(table, title="Installation Steps", expand=False)

class StepTracker:
    _instance = None

    def __init__(self, steps):
        if not StepTracker._instance:
            self.steps = steps.split('|')
            self.completed = set()
            self.layout = Layout()
            self.layout.split(
                Layout(name="steps", size=len(self.steps) + 3),
                Layout(name="output")
            )
            self.layout["steps"].update(create_steps_table(self.steps, self.completed))
            self.live = Live(self.layout, console=console, screen=True, refresh_per_second=4)
            StepTracker._instance = self

    @classmethod
    def get_instance(cls):
        return cls._instance

    def update_steps(self, completed):
        self.completed = set(int(x) for x in completed.split(',') if x)
        self.layout["steps"].update(create_steps_table(self.steps, self.completed))

    def print_output(self, message):
        self.layout["output"].update(Panel(message, expand=False))

    def start(self):
        self.live.start()

    def stop(self):
        self.live.stop()

def print_panel(message):
    tracker = StepTracker.get_instance()
    if tracker:
        tracker.print_output(message)
    else:
        console.print(Panel(message, expand=False))

def run_progress(total, description):
    progress = Progress()
    task = progress.add_task(description, total=total)
    tracker = StepTracker.get_instance()
    if tracker:
        tracker.layout["output"].update(progress)
    else:
        progress.start()
    while not progress.finished:
        progress.update(task, advance=1)
        time.sleep(0.1)
    if not tracker:
        progress.stop()

if __name__ == "__main__":
    print(f"Python script called with arguments: {sys.argv}", file=sys.stderr)
    action = sys.argv[1]
    if action == "init":
        StepTracker(sys.argv[2]).start()
    elif action == "panel":
        print_panel(sys.argv[2])
    elif action == "progress":
        run_progress(int(sys.argv[2]), sys.argv[3])
    elif action == "update_steps":
        tracker = StepTracker.get_instance()
        if tracker:
            tracker.update_steps(sys.argv[2])
    elif action == "stop":
        tracker = StepTracker.get_instance()
        if tracker:
            tracker.stop()
    print("Python script execution completed", file=sys.stderr)
