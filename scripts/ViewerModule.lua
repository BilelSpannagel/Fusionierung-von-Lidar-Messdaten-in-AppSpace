local ViewerModule = {}

function ViewerModule.PointCloudViewer(cloud)

  local Viewer = View.create()

  View.view(Viewer, cloud)
end

return ViewerModule

