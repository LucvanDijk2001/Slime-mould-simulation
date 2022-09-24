class Population
{
  SlimeAgent agents[]; 

  Population(int size)
  {
    agents = new SlimeAgent[size];
    for (int i = 0; i < size; i++)
    {
      agents[i] = new SlimeAgent();
    }
  }

  void Update()
  {
    for (int i = 0; i < agents.length; i++)
    {
      agents[i].Update();
    }
  }

  void Show()
  {
    for (int i = 0; i < agents.length; i++)
    {
      agents[i].Show();
    }
  }
}
