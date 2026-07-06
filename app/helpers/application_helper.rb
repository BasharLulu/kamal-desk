module ApplicationHelper
  def nav_link_class(current_path, target_path)
    base = "rounded-md px-3 py-2 transition"
    active = current_path == target_path
    active ? "#{base} bg-slate-800 text-white" : "#{base} text-slate-300 hover:bg-slate-900 hover:text-white"
  end

  def destination_chip_class(active)
    base = "rounded-full px-3 py-1 transition"
    active ? "#{base} bg-sky-600 text-white" : "#{base} bg-slate-800 text-slate-300 hover:bg-slate-700"
  end

  def status_badge_class(status)
    case status
    when "running" then "bg-amber-500/20 text-amber-200"
    when "succeeded" then "bg-emerald-500/20 text-emerald-200"
    when "failed" then "bg-red-500/20 text-red-200"
    else "bg-slate-700 text-slate-200"
    end
  end
end
