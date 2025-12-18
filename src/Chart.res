@react.component
let make = (~data) => {
  <div className="w-full h-64 bg-slate-800 rounded-lg p-4">
    <p className="text-white text-center">
      {React.string("Chart Component")}
    </p>
  </div>
}