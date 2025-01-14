state("SW3")
{
    bool loading        : 0x492D678;
    string100 objective : 0x4E05BF0, 0x8C8, 0x0; // UTF-16 all the time. Tends to start from the same address, and ends in 0x0. Everything inbetween can change between updates
    int cutsceneState   : "bink2w64.dll", 0x56310;
}

init 
{
    switch (modules.First().ModuleMemorySize)
    {
        case 0x83000: break;
        default: return;
    }

    // Grab the autosplitter from splits/layout
    var aslCmp = timer.Layout.Components.Append((timer.Run.AutoSplitter ?? new AutoSplitter()).Component)
                 .FirstOrDefault(c => c.GetType().Name == "ASLComponent");

    if (aslComponent == null)
        return;

    var script = aslCmp.GetType().GetProperty("Script").GetValue(aslCmp);
    script.GetType().GetField("_game", BindingFlags.NonPublic | BindingFlags.Instance).SetValue(script, null);
}

startup
{
    refreshRate = 30;

    // Checks if the current comparison is set to Real Time
    // Asks user to change to Game Time if LiveSplit is currently set to Real Time.
    if (timer.CurrentTimingMethod == TimingMethod.RealTime)
    {
        var timingMessage = MessageBox.Show (
            "This game uses Time without Loads (Game Time) as the main timing method.\n"+
            "LiveSplit is currently set to show Real Time (RTA).\n"+
            "Would you like to set the timing method to Game Time?",
            "LiveSplit | Shadow Warrior 3",
            MessageBoxButtons.YesNo, MessageBoxIcon.Question
        );

        if (timingMessage == DialogResult.Yes)
            timer.CurrentTimingMethod = TimingMethod.GameTime;
    }
}

onStart
{
    // This is part of a "cycle fix", makes sure the timer always starts at 0.00
    timer.IsGameTimePaused = true;
}

start
{
    // Start the timer when the loaded map changes from the Main Menu to Chapter 1 during the load screen
    return (current.objective == "/Game/Maps/Levels/01_The_Plan/01_The_Plan" && old.objective == "/Game/Maps/Levels/StartLevel");
}

split
{
    return current.objective != old.objective && current.objective != "/Game/Maps/Levels/StartLevel";
}

/*update
{
    print(current.cutsceneState.ToString());
}*/

isLoading
{
    return !current.loading || current.cutsceneState == 1;
}

exit
{
    timer.IsGameTimePaused = true;
}
